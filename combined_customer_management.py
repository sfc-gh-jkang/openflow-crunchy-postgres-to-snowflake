import streamlit as st
import pandas as pd
import traceback
from datetime import datetime
import re


# UPDATE POSTGRES AND SNOWFLAKE PARAMTERS FROM BELOW
#postgresql configuration
PG_HOST_NAME = "p.xxxxxxxxxxxxxxxxxxx.db.postgresbridge.com"
PG_PORT = "5432"
PG_USERNAME = "application"
PG_PASSWORD = "your password"
PG_DATABASE = "postgres"
PG_SCHEMA = "demo_retail"
PG_TABLE = "customers"

# Snowflake configuration
SF_ACCOUNT = "sfsehol-openflow-demo"
SF_USERNAME = "service_user_xxxx"
SF_DATABASE = "database_xxxx"
SF_SCHEMA = "demo_retail"
SF_TABLE = "customers"
SF_PRIVATE_KEY_PATH = "/path/to/your/private_key.p8"  # Update with your private key file path


# END OF UPDATE

# Page configuration
st.set_page_config(
    page_title="Demo : PostgreSQL CDC to Snowflake",
    page_icon="🗄️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Import database-specific modules
try:
    import psycopg2
    POSTGRES_AVAILABLE = True
except ImportError:
    POSTGRES_AVAILABLE = False

try:
    import snowflake.connector
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.serialization import load_pem_private_key
    import base64
    SNOWFLAKE_AVAILABLE = True
except ImportError:
    SNOWFLAKE_AVAILABLE = False

try:
    from faker import Faker
    fake = Faker()
    FAKER_AVAILABLE = True
except ImportError:
    FAKER_AVAILABLE = False

# ==========================================
# COMMON UTILITIES
# ==========================================

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_phone(phone):
    """Validate phone format (basic validation)"""
    pattern = r'^[\+]?[1-9][\d]{0,15}$'
    cleaned_phone = re.sub(r'[\s\-\(\)]', '', phone)
    return len(cleaned_phone) >= 10 and cleaned_phone.isdigit()

def validate_zipcode(zipcode):
    """Validate ZIP code format"""
    pattern = r'^\d{5}(-\d{4})?$'
    return re.match(pattern, zipcode) is not None

# ==========================================
# POSTGRESQL FUNCTIONS
# ==========================================

# PostgreSQL configuration
PG_DATABASE = "postgres"
PG_SCHEMA = "demo_retail"
PG_TABLE = "customers"

def create_pg_connection(host, port, database, username, password):
    """Create PostgreSQL connection"""
    if not POSTGRES_AVAILABLE:
        return None, "psycopg2 not available. Install with: pip install psycopg2-binary"

    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=username,
            password=password
        )
        return conn, None
    except Exception as e:
        return None, str(e)

def get_pg_customers(conn, limit=50, offset=0, search_term="", search_column=""):
    """Fetch customers from PostgreSQL with pagination and search"""
    try:
        cursor = conn.cursor()

        full_table_name = f'"{PG_SCHEMA}"."{PG_TABLE}"'
        base_query = f"SELECT * FROM {full_table_name}"
        count_query = f"SELECT COUNT(*) FROM {full_table_name}"

        where_clause = ""
        params = []

        if search_term and search_column:
            if search_column == "CustomerId":
                where_clause = f' WHERE "{search_column}" = %s'
                params = [int(search_term)]
            else:
                where_clause = f' WHERE UPPER("{search_column}") LIKE UPPER(%s)'
                params = [f"%{search_term}%"]

        # Get total count
        total_cursor = conn.cursor()
        total_cursor.execute(count_query + where_clause, params)
        total_count = total_cursor.fetchone()[0]
        total_cursor.close()

        # Get paginated results
        query = base_query + where_clause + f' ORDER BY "CustomerId" LIMIT %s OFFSET %s'
        cursor.execute(query, params + [limit, offset])

        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        cursor.close()

        df = pd.DataFrame(data, columns=columns)
        return df, total_count, None

    except Exception as e:
        return None, 0, str(e)

def insert_pg_customer(conn, customer_data):
    """Insert new customer record in PostgreSQL"""
    try:
        cursor = conn.cursor()

        query = f"""
        INSERT INTO "{PG_SCHEMA}"."{PG_TABLE}"
        ("FirstName", "LastName", "Email", "Phone", "Address", "City", "State", "ZipCode")
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        cursor.execute(query, customer_data)
        conn.commit()
        cursor.close()
        return True, "Customer added successfully!"

    except Exception as e:
        conn.rollback()
        return False, str(e)

def update_pg_customer(conn, customer_id, customer_data):
    """Update existing customer record in PostgreSQL"""
    try:
        cursor = conn.cursor()

        query = f"""
        UPDATE "{PG_SCHEMA}"."{PG_TABLE}"
        SET "FirstName"=%s, "LastName"=%s, "Email"=%s, "Phone"=%s,
            "Address"=%s, "City"=%s, "State"=%s, "ZipCode"=%s
        WHERE "CustomerId"=%s
        """

        cursor.execute(query, customer_data + [customer_id])
        conn.commit()
        cursor.close()
        return True, "Customer updated successfully!"

    except Exception as e:
        conn.rollback()
        return False, str(e)

def delete_pg_customer(conn, customer_id):
    """Delete customer record from PostgreSQL"""
    try:
        cursor = conn.cursor()

        query = f'DELETE FROM "{PG_SCHEMA}"."{PG_TABLE}" WHERE "CustomerId"=%s'
        cursor.execute(query, [customer_id])
        conn.commit()
        cursor.close()
        return True, "Customer deleted successfully!"

    except Exception as e:
        conn.rollback()
        return False, str(e)

def get_pg_customer_by_id(conn, customer_id):
    """Get single customer by ID from PostgreSQL"""
    try:
        cursor = conn.cursor()
        query = f'SELECT * FROM "{PG_SCHEMA}"."{PG_TABLE}" WHERE "CustomerId"=%s'
        cursor.execute(query, [customer_id])

        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchone()
        cursor.close()

        if data:
            return dict(zip(columns, data)), None
        else:
            return None, "Customer not found"

    except Exception as e:
        return None, str(e)

def generate_random_customers(num_records=100):
    """Generate random customer data"""
    if not FAKER_AVAILABLE:
        return []

    customers = []
    for _ in range(num_records):
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = f"{first_name.lower()}.{last_name.lower()}@{fake.domain_name()}"
        phone = fake.phone_number()[:10]
        address = fake.street_address()
        city = fake.city()
        state = fake.state_abbr()
        zip_code = fake.zipcode()

        customers.append((first_name, last_name, email, phone, address, city, state, zip_code))

    return customers

def bulk_insert_pg_customers(conn, customers_data):
    """Bulk insert customer records into PostgreSQL"""
    try:
        cursor = conn.cursor()

        query = f"""
        INSERT INTO "{PG_SCHEMA}"."{PG_TABLE}"
        ("FirstName", "LastName", "Email", "Phone", "Address", "City", "State", "ZipCode")
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        cursor.executemany(query, customers_data)
        conn.commit()
        count = cursor.rowcount
        cursor.close()
        return True, f"{count} customers inserted successfully!", count

    except Exception as e:
        conn.rollback()
        return False, str(e), 0

def get_pg_table_stats(conn):
    """Get PostgreSQL table statistics"""
    try:
        cursor = conn.cursor()
        query = f'SELECT COUNT(*) FROM "{PG_SCHEMA}"."{PG_TABLE}"'
        cursor.execute(query)
        count = cursor.fetchone()[0]
        cursor.close()
        return count, None
    except Exception as e:
        return 0, str(e)

def test_pg_connection(host, port, database, username, password):
    """Test PostgreSQL database connection"""
    try:
        conn, error = create_pg_connection(host, port, database, username, password)
        if conn:
            cursor = conn.cursor()
            cursor.execute("SELECT version()")
            version = cursor.fetchone()[0]
            cursor.close()
            conn.close()
            return True, f"PostgreSQL {version}"
        else:
            return False, error
    except Exception as e:
        return False, str(e)

# ==========================================
# SNOWFLAKE FUNCTIONS
# ==========================================



def check_sf_dependencies():
    """Check if all required Snowflake dependencies are available"""
    missing_deps = []

    if not SNOWFLAKE_AVAILABLE:
        missing_deps.extend(["snowflake-connector-python", "cryptography"])

    try:
        import jwt
    except ImportError:
        missing_deps.append("PyJWT")

    return missing_deps

def read_private_key_from_file(file_path):
    """Read private key from file"""
    try:
        with open(file_path, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        raise ValueError(f"Private key file not found: {file_path}")
    except PermissionError:
        raise ValueError(f"Permission denied reading file: {file_path}")
    except Exception as e:
        raise ValueError(f"Error reading private key file: {str(e)}")

def parse_private_key(private_key_str):
    """Parse and validate the private key string"""
    try:
        private_key_str = private_key_str.strip()

        if private_key_str.startswith('-----BEGIN'):
            private_key_bytes = private_key_str.encode('utf-8')
        else:
            try:
                private_key_bytes = base64.b64decode(private_key_str)
            except:
                private_key_bytes = private_key_str.encode('utf-8')

        try:
            private_key = load_pem_private_key(private_key_bytes, password=None)
        except ValueError as e:
            if "encrypted" in str(e).lower():
                raise ValueError("Private key appears to be encrypted. Please provide an unencrypted private key.")
            else:
                raise ValueError(f"Invalid private key format: {str(e)}")

        private_key_der = private_key.private_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )

        return private_key_der
    except Exception as e:
        raise ValueError(f"Private key processing error: {str(e)}")

def create_sf_connection(private_key_input, is_file_path=False):
    """Create Snowflake connection"""
    try:
        missing_deps = check_sf_dependencies()
        if missing_deps:
            return None, f"Missing required dependencies: {', '.join(missing_deps)}"

        if is_file_path:
            private_key_str = read_private_key_from_file(private_key_input)
        else:
            private_key_str = private_key_input

        private_key_der = parse_private_key(private_key_str)

        conn = snowflake.connector.connect(
            user=SF_USERNAME,
            account=SF_ACCOUNT,
            private_key=private_key_der,
            database=SF_DATABASE,
            schema=SF_SCHEMA,
            client_session_keep_alive=True,
            authenticator='snowflake_jwt'
        )

        return conn, None

    except Exception as e:
        error_message = str(e)
        if "jwt" in error_message.lower():
            error_message += "\n\nJWT Error - Try installing: pip install PyJWT==2.8.0"
        elif "private_key" in error_message.lower():
            error_message += "\n\nPrivate Key Error - Ensure your key is in PEM format and unencrypted"
        elif "account" in error_message.lower():
            error_message += "\n\nAccount Error - Check your account identifier"

        return None, error_message

def test_sf_connection(private_key_input, is_file_path=False):
    """Test the Snowflake connection"""
    try:
        conn, error = create_sf_connection(private_key_input, is_file_path)
        if conn:
            cursor = conn.cursor()
            cursor.execute("SELECT CURRENT_VERSION()")
            version = cursor.fetchone()[0]

            cursor.execute("SELECT CURRENT_USER()")
            user = cursor.fetchone()[0]

            cursor.execute("SELECT CURRENT_ROLE()")
            role = cursor.fetchone()[0]

            cursor.execute("SELECT CURRENT_DATABASE()")
            database = cursor.fetchone()[0]

            cursor.execute("SELECT CURRENT_SCHEMA()")
            schema = cursor.fetchone()[0]

            cursor.close()
            conn.close()

            return True, {
                'version': version,
                'user': user,
                'role': role,
                'database': database,
                'schema': schema
            }
        else:
            return False, error
    except Exception as e:
        return False, str(e)

def get_sf_customer_data(conn, limit=50, offset=0, search_term="", search_column=""):
    """Fetch customer data from Snowflake"""
    try:
        cursor = conn.cursor()

        full_table_name = f'"{SF_SCHEMA}"."{SF_TABLE}"'
        base_query = f"SELECT * FROM {full_table_name}"
        count_query = f"SELECT COUNT(*) FROM {full_table_name}"

        where_clause = ""
        params = []

        if search_term and search_column:
            if search_column.upper() == "CUSTOMERID":
                where_clause = f' WHERE "{search_column}" = %s'
                params = [int(search_term)]
            else:
                where_clause = f' WHERE UPPER("{search_column}") LIKE UPPER(%s)'
                params = [f"%{search_term}%"]

        # Get total count
        total_cursor = conn.cursor()
        total_cursor.execute(count_query + where_clause, params)
        total_count = total_cursor.fetchone()[0]
        total_cursor.close()

        # Get paginated results
        query = base_query + where_clause + f' ORDER BY "CustomerId" LIMIT %s OFFSET %s'
        cursor.execute(query, params + [limit, offset])

        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        cursor.close()

        df = pd.DataFrame(data, columns=columns)
        return df, total_count, None

    except Exception as e:
        return None, 0, str(e)

def get_sf_table_info(conn):
    """Get Snowflake table structure information"""
    try:
        cursor = conn.cursor()
        query = f'DESCRIBE TABLE {SF_DATABASE}."{SF_SCHEMA}".{SF_TABLE}'
        cursor.execute(query)

        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        cursor.close()

        df = pd.DataFrame(data, columns=columns)
        return df, None

    except Exception as e:
        return None, str(e)

# ==========================================
# UI COMPONENTS
# ==========================================

def main_navigation():
    """Main navigation sidebar"""
    with st.sidebar:
        st.title("🗄️ Multi-DB Customer Management")

        # Database selection
        db_options = []
        if POSTGRES_AVAILABLE:
            db_options.append("🐘 PostgreSQL CrunchyBridge")
        if SNOWFLAKE_AVAILABLE:
            db_options.append("❄️ Snowflake ")

        if not db_options:
            st.error("No database libraries available!")
            st.code("pip install psycopg2-binary snowflake-connector-python cryptography PyJWT")
            return None

        selected_db = st.selectbox(
            "Choose Database System:",
            db_options,
            index=0
        )

        st.markdown("---")



        return selected_db

def pg_connection_sidebar():
    """PostgreSQL connection sidebar"""
    st.header("🐘 PostgreSQL Connection")

    if 'pg_connected' not in st.session_state:
        st.session_state.pg_connected = False
        st.session_state.pg_connection = None

    if not st.session_state.pg_connected:
        with st.form("pg_connection_form"):
            host = st.text_input("Host *", value=PG_HOST_NAME)
            port = st.text_input("Port *", value=PG_PORT)
            database = st.text_input("Database *", value=PG_DATABASE)
            username = st.text_input("Username *", value=PG_USERNAME)
            password = st.text_input("Password *", value=PG_PASSWORD, type="default")

            col1, col2 = st.columns(2)
            with col1:
                test_btn = st.form_submit_button("🧪 Test", type="secondary")
            with col2:
                connect_btn = st.form_submit_button("🔌 Connect", type="primary")

            if test_btn:
                if host and port and database and username and password:
                    with st.spinner("Testing connection..."):
                        success, message = test_pg_connection(host, port, database, username, password)
                        if success:
                            st.success(f"✅ Connection successful!\n{message}")
                        else:
                            st.error(f"❌ Connection failed: {message}")
                else:
                    st.error("Please fill in all required fields")

            if connect_btn:
                if host and port and database and username and password:
                    with st.spinner("Connecting to PostgreSQL..."):
                        conn, error = create_pg_connection(host, port, database, username, password)

                        if conn:
                            st.session_state.pg_connected = True
                            st.session_state.pg_connection = conn
                            st.session_state.pg_database = database
                            st.success("✅ Connected successfully!")
                            st.rerun()
                        else:
                            st.error(f"❌ Connection failed: {error}")
                else:
                    st.error("Please fill in all required fields")
    else:
        st.success("✅ Connected to PostgreSQL")
        st.info(f"Database: {st.session_state.get('pg_database', 'N/A')}\nSchema: {PG_SCHEMA}\nTable: {PG_TABLE}")

        if st.button("🔌 Disconnect", type="secondary"):
            if st.session_state.pg_connection:
                st.session_state.pg_connection.close()
            st.session_state.pg_connected = False
            st.session_state.pg_connection = None
            st.rerun()

def sf_connection_sidebar():
    """Snowflake connection sidebar"""
    st.header("❄️ Snowflake Connection")

    # Display connection information
    st.info(f"""
    **Connection Details:**
    - **Account:** {SF_ACCOUNT}
    - **Username:** {SF_USERNAME}
    - **Database:** {SF_DATABASE}
    - **Schema:** {SF_SCHEMA}
    - **Table:** {SF_TABLE}
    """)

    if 'sf_connected' not in st.session_state:
        st.session_state.sf_connected = False
        st.session_state.sf_connection = None

    if not st.session_state.sf_connected:
        with st.form("sf_connection_form"):
            st.markdown("**Private Key Authentication**")

            key_input_method = st.radio(
                "Choose private key input method:",
                ["File Path", "Paste Content"],
                index=0,
                horizontal=True
            )

            private_key_input = ""
            is_file_path = False

            if key_input_method == "File Path":
                is_file_path = True
                private_key_input = st.text_input(
                    "Private Key File Path *",
                    value=SF_PRIVATE_KEY_PATH,
                    placeholder="/path/to/your/private_key.p8"
                )
            else:
                private_key_input = st.text_area(
                    "Private Key Content *",
                    height=200,
                    placeholder="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
                )

            col1, col2 = st.columns(2)
            with col1:
                test_btn = st.form_submit_button("🧪 Test", type="secondary")
            with col2:
                connect_btn = st.form_submit_button("🔌 Connect", type="primary")

            if test_btn:
                if private_key_input:
                    with st.spinner("Testing connection..."):
                        success, result = test_sf_connection(private_key_input, is_file_path)
                        if success:
                            st.success("✅ Connection successful!")
                            st.json(result)
                        else:
                            st.error(f"❌ Connection failed:\n{result}")
                else:
                    st.error("Please provide your private key")

            if connect_btn:
                if private_key_input:
                    with st.spinner("Connecting to Snowflake..."):
                        conn, error = create_sf_connection(private_key_input, is_file_path)

                        if conn:
                            st.session_state.sf_connected = True
                            st.session_state.sf_connection = conn
                            st.success("✅ Connected successfully!")
                            st.rerun()
                        else:
                            st.error(f"❌ Connection failed:\n{error}")
                else:
                    st.error("Please provide your private key")
    else:
        st.success("✅ Connected to Snowflake")

        if st.button("🔌 Disconnect", type="secondary"):
            if st.session_state.sf_connection:
                st.session_state.sf_connection.close()
            st.session_state.sf_connected = False
            st.session_state.sf_connection = None
            st.rerun()

# ==========================================
# POSTGRESQL APPLICATION
# ==========================================

def postgresql_app():
    """PostgreSQL CRUD Application"""
    st.title("🐘 Customer Management System (PostgreSQL)")
    st.markdown(f"Manage customer records in `{PG_SCHEMA}.{PG_TABLE}` table")

    # Connection sidebar
    with st.sidebar:
        pg_connection_sidebar()

    if not st.session_state.get('pg_connected', False):
        st.warning("👈 Please connect to PostgreSQL using the sidebar to continue.")
        st.info("""
        **Setup Instructions:**
        1. Make sure PostgreSQL is running
        2. Create database and table structure as needed
        3. Use the connection form in the sidebar
        """)
        st.stop()

    # Main application tabs
    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "📋 View Customers",
        "➕ Add Customer",
        "✏️ Update Customer",
        "🗑️ Delete Customer",
        "🔄 Bulk Operations"
    ])

    conn = st.session_state.pg_connection

    with tab1:
        st.subheader("📋 Customer Records")

        # Search and filter controls
        col1, col2, col3 = st.columns([2, 2, 1])

        with col1:
            search_column = st.selectbox(
                "Search by:",
                ["", "CustomerId", "FirstName", "LastName", "Email", "Phone", "City", "State", "ZipCode"]
            )

        with col2:
            search_term = st.text_input("Search term:")

        with col3:
            st.write("")
            search_btn = st.button("🔍 Search", type="primary")

        # Pagination controls
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            page_size = st.selectbox("Records per page:", [10, 25, 50, 100], index=1)

        # Initialize pagination
        if 'pg_current_page' not in st.session_state:
            st.session_state.pg_current_page = 0

        if search_btn or search_term == "":
            st.session_state.pg_current_page = 0

        offset = st.session_state.pg_current_page * page_size

        # Fetch and display data
        df, total_count, error = get_pg_customers(
            conn,
            limit=page_size,
            offset=offset,
            search_term=search_term,
            search_column=search_column
        )

        if error:
            st.error(f"Error fetching data: {error}")
        elif df is not None and not df.empty:
            st.dataframe(df, use_container_width=True)

            # Pagination buttons
            total_pages = (total_count + page_size - 1) // page_size

            col1, col2, col3, col4, col5 = st.columns([1, 1, 2, 1, 1])

            with col1:
                if st.button("⬅️ Previous") and st.session_state.pg_current_page > 0:
                    st.session_state.pg_current_page -= 1
                    st.rerun()

            with col3:
                st.markdown(f"<center>Page {st.session_state.pg_current_page + 1} of {total_pages}<br>Total records: {total_count}</center>", unsafe_allow_html=True)

            with col5:
                if st.button("Next ➡️") and st.session_state.pg_current_page < total_pages - 1:
                    st.session_state.pg_current_page += 1
                    st.rerun()
        else:
            st.info("No customers found.")

    with tab2:
        st.subheader("➕ Add New Customer")

        with st.form("add_customer_form"):
            col1, col2 = st.columns(2)

            with col1:
                first_name = st.text_input("First Name *")
                last_name = st.text_input("Last Name *")
                email = st.text_input("Email *")
                phone = st.text_input("Phone *")

            with col2:
                address = st.text_input("Address")
                city = st.text_input("City")
                state = st.text_input("State")
                zipcode = st.text_input("ZIP Code")

            submit_btn = st.form_submit_button("➕ Add Customer", type="primary")

            if submit_btn:
                # Validation
                errors = []
                if not first_name: errors.append("First Name is required")
                if not last_name: errors.append("Last Name is required")
                if not email: errors.append("Email is required")
                elif not validate_email(email): errors.append("Invalid email format")
                if not phone: errors.append("Phone is required")
                elif not validate_phone(phone): errors.append("Invalid phone format")
                if zipcode and not validate_zipcode(zipcode): errors.append("Invalid ZIP code format")

                if errors:
                    for error in errors:
                        st.error(error)
                else:
                    customer_data = [first_name, last_name, email, phone, address, city, state, zipcode]
                    success, message = insert_pg_customer(conn, customer_data)

                    if success:
                        st.success(message)
                        st.balloons()
                    else:
                        st.error(f"Error adding customer: {message}")

    with tab3:
        st.subheader("✏️ Update Customer")

        customer_id = st.number_input("Enter Customer ID to update:", min_value=1, step=1)

        if st.button("🔍 Load Customer Data"):
            if customer_id:
                customer_data, error = get_pg_customer_by_id(conn, customer_id)
                if customer_data:
                    st.session_state.pg_update_customer_data = customer_data
                    st.success("Customer data loaded!")
                else:
                    st.error(error or "Customer not found")

        if 'pg_update_customer_data' in st.session_state:
            customer_data = st.session_state.pg_update_customer_data

            with st.form("update_customer_form"):
                st.info(f"Updating Customer ID: {customer_data['CustomerId']}")

                col1, col2 = st.columns(2)

                with col1:
                    first_name = st.text_input("First Name *", value=customer_data.get('FirstName', ''))
                    last_name = st.text_input("Last Name *", value=customer_data.get('LastName', ''))
                    email = st.text_input("Email *", value=customer_data.get('Email', ''))
                    phone = st.text_input("Phone *", value=customer_data.get('Phone', ''))

                with col2:
                    address = st.text_input("Address", value=customer_data.get('Address', '') or '')
                    city = st.text_input("City", value=customer_data.get('City', '') or '')
                    state = st.text_input("State", value=customer_data.get('State', '') or '')
                    zipcode = st.text_input("ZIP Code", value=customer_data.get('ZipCode', '') or '')

                update_btn = st.form_submit_button("✏️ Update Customer", type="primary")

                if update_btn:
                    # Validation
                    errors = []
                    if not first_name: errors.append("First Name is required")
                    if not last_name: errors.append("Last Name is required")
                    if not email: errors.append("Email is required")
                    elif not validate_email(email): errors.append("Invalid email format")
                    if not phone: errors.append("Phone is required")
                    elif not validate_phone(phone): errors.append("Invalid phone format")
                    if zipcode and not validate_zipcode(zipcode): errors.append("Invalid ZIP code format")

                    if errors:
                        for error in errors:
                            st.error(error)
                    else:
                        update_data = [first_name, last_name, email, phone, address, city, state, zipcode]
                        success, message = update_pg_customer(conn, customer_data['CustomerId'], update_data)

                        if success:
                            st.success(message)
                            del st.session_state.pg_update_customer_data
                            st.balloons()
                        else:
                            st.error(f"Error updating customer: {message}")

    with tab4:
        st.subheader("🗑️ Delete Customer")

        customer_id = st.number_input("Enter Customer ID to delete:", min_value=1, step=1, key="pg_delete_id")

        if st.button("🔍 Preview Customer"):
            if customer_id:
                customer_data, error = get_pg_customer_by_id(conn, customer_id)
                if customer_data:
                    st.session_state.pg_delete_customer_data = customer_data
                    st.success("Customer data loaded!")
                else:
                    st.error(error or "Customer not found")

        if 'pg_delete_customer_data' in st.session_state:
            customer_data = st.session_state.pg_delete_customer_data

            st.warning("⚠️ **Customer to be deleted:**")

            col1, col2 = st.columns(2)
            with col1:
                st.info(f"""
                **Customer ID:** {customer_data['CustomerId']}
                **Name:** {customer_data.get('FirstName', '')} {customer_data.get('LastName', '')}
                **Email:** {customer_data.get('Email', '')}
                **Phone:** {customer_data.get('Phone', '')}
                """)

            with col2:
                st.info(f"""
                **Address:** {customer_data.get('Address', '') or 'N/A'}
                **City:** {customer_data.get('City', '') or 'N/A'}
                **State:** {customer_data.get('State', '') or 'N/A'}
                **ZIP Code:** {customer_data.get('ZipCode', '') or 'N/A'}
                """)

            st.error("🚨 **WARNING: This action cannot be undone!**")

            confirm = st.checkbox("I understand that this action is permanent and cannot be undone")

            col1, col2, col3 = st.columns([1, 1, 1])
            with col2:
                if st.button("🗑️ DELETE CUSTOMER", type="primary", disabled=not confirm):
                    success, message = delete_pg_customer(conn, customer_data['CustomerId'])

                    if success:
                        st.success(message)
                        del st.session_state.pg_delete_customer_data
                        st.balloons()
                    else:
                        st.error(f"Error deleting customer: {message}")

    with tab5:
        st.subheader("🔄 Bulk Operations")

        if not FAKER_AVAILABLE:
            st.error("Faker library not available. Install with: pip install faker")
            st.stop()

        # Get current table stats
        current_count, error = get_pg_table_stats(conn)
        if error:
            st.error(f"Error getting table stats: {error}")
        else:
            st.info(f"📊 Current total customers in database: **{current_count:,}**")

        st.markdown("---")

        # Bulk Insert Section
        st.subheader("📥 Bulk Insert Random Customers")
        st.write("Generate and insert multiple random customer records using realistic fake data.")

        col1, col2 = st.columns([2, 1])

        with col1:
            num_records = st.number_input(
                "Number of records to generate:",
                min_value=1,
                max_value=10000,
                value=100,
                step=1
            )

        with col2:
            st.write("")
            st.write("")
            preview_btn = st.button("👀 Preview Sample", type="secondary")

        # Preview sample data
        if preview_btn:
            with st.spinner("Generating sample data..."):
                sample_data = generate_random_customers(min(5, num_records))
                df_sample = pd.DataFrame(sample_data, columns=[
                    "FirstName", "LastName", "Email", "Phone", "Address", "City", "State", "ZipCode"
                ])
                st.write("**Sample data preview:**")
                st.dataframe(df_sample, use_container_width=True)

        st.markdown("---")

        # Bulk insert controls
        col1, col2, col3 = st.columns([1, 2, 1])

        with col2:
            if st.button(f"🚀 Generate & Insert {num_records:,} Records", type="primary", use_container_width=True):
                if num_records > 1000:
                    st.warning(f"⚠️ You're about to insert {num_records:,} records. This may take a while.")

                    if not st.checkbox(f"I confirm I want to insert {num_records:,} records"):
                        st.stop()

                # Generate data
                with st.spinner(f"Generating {num_records:,} random customer records..."):
                    try:
                        customers_data = generate_random_customers(num_records)
                        st.success(f"✅ Generated {len(customers_data):,} customer records")
                    except Exception as e:
                        st.error(f"❌ Error generating data: {str(e)}")
                        st.stop()

                # Insert data
                with st.spinner(f"Inserting {num_records:,} records into database..."):
                    try:
                        success, message, count = bulk_insert_pg_customers(conn, customers_data)

                        if success:
                            st.success(f"🎉 {message}")
                            st.balloons()

                            # Show updated stats
                            new_count, _ = get_pg_table_stats(conn)
                            if new_count:
                                st.info(f"📊 Updated total customers in database: **{new_count:,}** (+{count:,})")

                            # Show summary
                            col1, col2, col3 = st.columns(3)
                            with col1:
                                st.metric("Records Inserted", f"{count:,}")
                            with col2:
                                st.metric("Total in Database", f"{new_count:,}" if new_count else "N/A")
                            with col3:
                                insertion_rate = count / max(1, num_records) * 100
                                st.metric("Success Rate", f"{insertion_rate:.1f}%")
                        else:
                            st.error(f"❌ Error inserting data: {message}")
                    except Exception as e:
                        st.error(f"❌ Unexpected error: {str(e)}")

# ==========================================
# SNOWFLAKE APPLICATION
# ==========================================

def snowflake_app():
    """Snowflake Viewer Application"""
    st.title("❄️ Snowflake Customer Viewer")
    st.markdown(f"View customer records from `{SF_DATABASE}.{SF_SCHEMA}.{SF_TABLE}`")

    # Check dependencies upfront
    missing_deps = check_sf_dependencies()
    if missing_deps:
        st.error("🚨 **Missing Required Dependencies**")
        st.code(f"pip install {' '.join(missing_deps)}")
        st.markdown("Please install the above dependencies before using this app.")
        st.stop()

    # Connection sidebar
    with st.sidebar:
        sf_connection_sidebar()

    if not st.session_state.get('sf_connected', False):
        st.warning("👈 Please connect to Snowflake using the sidebar to continue.")
        st.info(f"""
        **About this app:**
        - Connects to Snowflake account: `{SF_ACCOUNT}`
        - Uses key pair authentication for user: `{SF_USERNAME}`
        - Displays data from: `{SF_DATABASE}.{SF_SCHEMA}.{SF_TABLE}`
        - Provides search and pagination functionality
        """)
        st.stop()

    # Main application tabs
    tab1, tab2 = st.tabs(["📋 Customer Data", "📊 Table Info"])

    conn = st.session_state.sf_connection

    with tab1:
        st.subheader("📋 Customer Records")

        # Search and filter controls
        col1, col2, col3 = st.columns([2, 2, 1])

        with col1:
            search_column = st.selectbox(
                "Search by column:",
                ["", "CustomerId", "FirstName", "LastName", "Email", "Phone", "Address", "City", "State", "ZipCode"]
            )

        with col2:
            search_term = st.text_input("Search term:")

        with col3:
            st.write("")
            search_btn = st.button("🔍 Search", type="primary")

        # Pagination controls
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            page_size = st.selectbox("Records per page:", [10, 25, 50, 100], index=2)

        # Initialize pagination
        if 'sf_current_page' not in st.session_state:
            st.session_state.sf_current_page = 0

        if search_btn or search_term == "":
            st.session_state.sf_current_page = 0

        offset = st.session_state.sf_current_page * page_size

        # Fetch and display data
        with st.spinner("Loading customer data..."):
            df, total_count, error = get_sf_customer_data(
                conn,
                limit=page_size,
                offset=offset,
                search_term=search_term,
                search_column=search_column
            )

        if error:
            st.error(f"Error fetching data: {error}")
        elif df is not None and not df.empty:
            # Display metrics
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("Total Records", total_count)
            with col2:
                st.metric("Current Page", st.session_state.sf_current_page + 1)
            with col3:
                total_pages = (total_count + page_size - 1) // page_size
                st.metric("Total Pages", total_pages)
            with col4:
                st.metric("Records Shown", len(df))

            # Display data table
            st.dataframe(
                df,
                use_container_width=True,
                height=400,
                column_config={
                    "CustomerId": st.column_config.NumberColumn("Customer ID"),
                    "FirstName": st.column_config.TextColumn("First Name"),
                    "LastName": st.column_config.TextColumn("Last Name"),
                    "Email": st.column_config.TextColumn("Email"),
                    "Phone": st.column_config.TextColumn("Phone"),
                    "Address": st.column_config.TextColumn("Address"),
                    "City": st.column_config.TextColumn("City"),
                    "State": st.column_config.TextColumn("State"),
                    "ZipCode": st.column_config.TextColumn("ZIP Code")
                }
            )

            # Pagination buttons
            st.markdown("---")
            col1, col2, col3, col4, col5 = st.columns([1, 1, 2, 1, 1])

            with col1:
                if st.button("⏮️ First") and st.session_state.sf_current_page > 0:
                    st.session_state.sf_current_page = 0
                    st.rerun()

            with col2:
                if st.button("⬅️ Previous") and st.session_state.sf_current_page > 0:
                    st.session_state.sf_current_page -= 1
                    st.rerun()

            with col3:
                st.markdown(f"<center>Page {st.session_state.sf_current_page + 1} of {total_pages}</center>", unsafe_allow_html=True)

            with col4:
                if st.button("Next ➡️") and st.session_state.sf_current_page < total_pages - 1:
                    st.session_state.sf_current_page += 1
                    st.rerun()

            with col5:
                if st.button("Last ⏭️") and st.session_state.sf_current_page < total_pages - 1:
                    st.session_state.sf_current_page = total_pages - 1
                    st.rerun()

        else:
            st.info("No customer records found.")

    with tab2:
        st.subheader("📊 Table Structure")

        with st.spinner("Loading table information..."):
            table_info, error = get_sf_table_info(conn)

        if error:
            st.error(f"Error getting table info: {error}")
        elif table_info is not None and not table_info.empty:
            st.dataframe(table_info, use_container_width=True)

            # Display summary
            st.markdown("**Table Summary:**")
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Total Columns", len(table_info))
            with col2:
                nullable_count = table_info[table_info['null?'] == 'Y'].shape[0] if 'null?' in table_info.columns else 0
                st.metric("Nullable Columns", nullable_count)
        else:
            st.info("No table information available.")

# ==========================================
# MAIN APPLICATION
# ==========================================

def main():
    """Main application entry point"""

    # Main navigation
    selected_db = main_navigation()

    if selected_db is None:
        return

    # Route to appropriate application
    if "PostgreSQL" in selected_db:
        postgresql_app()
    elif "Snowflake" in selected_db:
        snowflake_app()

if __name__ == "__main__":
    main()
