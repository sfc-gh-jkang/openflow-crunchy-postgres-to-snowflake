--
-- applicationQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: demo_retail; Type: SCHEMA; Schema: -; Owner: application
--drop schema if exists retail cascade;

--
drop schema if exists demo_retail cascade;
CREATE SCHEMA if not exists demo_retail;


ALTER SCHEMA demo_retail OWNER TO application;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.categories (
    "CategoryId" integer NOT NULL,
    "CategoryName" character varying(100) NOT NULL,
    "Description" text
);


ALTER TABLE demo_retail.categories OWNER TO application;

--
-- Name: categories_CategoryId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."categories_CategoryId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."categories_CategoryId_seq" OWNER TO application;

--
-- Name: categories_CategoryId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."categories_CategoryId_seq" OWNED BY demo_retail.categories."CategoryId";


--
-- Name: customers; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.customers (
    "CustomerId" integer NOT NULL,
    "FirstName" character varying(50) NOT NULL,
    "LastName" character varying(50) NOT NULL,
    "Email" character varying(100) NOT NULL,
    "Phone" character varying(20),
    "Address" character varying(255),
    "City" character varying(100),
    "State" character varying(50),
    "ZipCode" character varying(10),
    "DateCreated" timestamp without time zone DEFAULT now(),
    "LastUpdated" timestamp without time zone DEFAULT now()
);


ALTER TABLE demo_retail.customers OWNER TO application;

--
-- Name: customers_CustomerId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."customers_CustomerId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."customers_CustomerId_seq" OWNER TO application;

--
-- Name: customers_CustomerId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."customers_CustomerId_seq" OWNED BY demo_retail.customers."CustomerId";


--
-- Name: orderitems; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.orderitems (
    "OrderItemId" integer NOT NULL,
    "OrderId" integer NOT NULL,
    "ProductId" integer NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(10,2) NOT NULL
);


ALTER TABLE demo_retail.orderitems OWNER TO application;

--
-- Name: orderitems_OrderItemId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."orderitems_OrderItemId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."orderitems_OrderItemId_seq" OWNER TO application;

--
-- Name: orderitems_OrderItemId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."orderitems_OrderItemId_seq" OWNED BY demo_retail.orderitems."OrderItemId";


--
-- Name: orders; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.orders (
    "OrderId" integer NOT NULL,
    "CustomerId" integer NOT NULL,
    "OrderDate" timestamp without time zone DEFAULT now(),
    "TotalAmount" numeric(10,2) NOT NULL,
    "OrderStatus" character varying(50) NOT NULL,
    "ShippingAddress" character varying(255),
    "ShippingCity" character varying(100),
    "ShippingState" character varying(50),
    "ShippingZipCode" character varying(10)
);


ALTER TABLE demo_retail.orders OWNER TO application;

--
-- Name: orders_OrderId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."orders_OrderId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."orders_OrderId_seq" OWNER TO application;

--
-- Name: orders_OrderId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."orders_OrderId_seq" OWNED BY demo_retail.orders."OrderId";


--
-- Name: productcategories; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.productcategories (
    "ProductId" integer NOT NULL,
    "CategoryId" integer NOT NULL
);


ALTER TABLE demo_retail.productcategories OWNER TO application;

--
-- Name: products; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.products (
    "ProductId" integer NOT NULL,
    "ProductName" character varying(100) NOT NULL,
    "Description" text,
    "Price" numeric(10,2) NOT NULL,
    "StockQuantity" integer NOT NULL,
    "DateAdded" timestamp without time zone DEFAULT now(),
    "LastUpdated" timestamp without time zone DEFAULT now()
);


ALTER TABLE demo_retail.products OWNER TO application;

--
-- Name: products_ProductId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."products_ProductId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."products_ProductId_seq" OWNER TO application;

--
-- Name: products_ProductId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."products_ProductId_seq" OWNED BY demo_retail.products."ProductId";


--
-- Name: reviews; Type: TABLE; Schema: demo_retail; Owner: application
--

CREATE TABLE demo_retail.reviews (
    "ReviewId" integer NOT NULL,
    "ProductId" integer NOT NULL,
    "CustomerId" integer NOT NULL,
    "Rating" integer NOT NULL,
    "Comment" text,
    "ReviewDate" timestamp without time zone DEFAULT now()
);


ALTER TABLE demo_retail.reviews OWNER TO application;

--
-- Name: reviews_ReviewId_seq; Type: SEQUENCE; Schema: demo_retail; Owner: application
--

CREATE SEQUENCE demo_retail."reviews_ReviewId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE demo_retail."reviews_ReviewId_seq" OWNER TO application;

--
-- Name: reviews_ReviewId_seq; Type: SEQUENCE OWNED BY; Schema: demo_retail; Owner: application
--

ALTER SEQUENCE demo_retail."reviews_ReviewId_seq" OWNED BY demo_retail.reviews."ReviewId";


--
-- Name: categories CategoryId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.categories ALTER COLUMN "CategoryId" SET DEFAULT nextval('demo_retail."categories_CategoryId_seq"'::regclass);


--
-- Name: customers CustomerId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.customers ALTER COLUMN "CustomerId" SET DEFAULT nextval('demo_retail."customers_CustomerId_seq"'::regclass);


--
-- Name: orderitems OrderItemId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orderitems ALTER COLUMN "OrderItemId" SET DEFAULT nextval('demo_retail."orderitems_OrderItemId_seq"'::regclass);


--
-- Name: orders OrderId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orders ALTER COLUMN "OrderId" SET DEFAULT nextval('demo_retail."orders_OrderId_seq"'::regclass);


--
-- Name: products ProductId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.products ALTER COLUMN "ProductId" SET DEFAULT nextval('demo_retail."products_ProductId_seq"'::regclass);


--
-- Name: reviews ReviewId; Type: DEFAULT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.reviews ALTER COLUMN "ReviewId" SET DEFAULT nextval('demo_retail."reviews_ReviewId_seq"'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.categories ("CategoryId", "CategoryName", "Description") FROM stdin;
1	Electronics	Devices and gadgets
2	Peripherals	Computer accessories
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.customers ("CustomerId", "FirstName", "LastName", "Email", "Phone", "Address", "City", "State", "ZipCode", "DateCreated", "LastUpdated") FROM stdin;
1	Alice	Smith	alice.smith@example.com	555-111-2222	123 Main St	Anytown	CA	90210	2025-07-02 14:05:01.529123	2025-07-02 14:05:01.529123
2	Bob	Johnson	bob.johnson@example.com	555-333-4444	456 Oak Ave	Otherville	NY	10001	2025-07-02 14:05:01.529123	2025-07-02 14:05:01.529123
20	KAVIN	Kim	brian.kim@collier.com	1-816-3424-5846	28323 Villa Road Suite 801	North Courtneyside	WI	42536	2025-07-28 16:30:40.509139	2025-07-28 22:18:16.179603
3	Umesh	Patel	umpatel@email.com	123-53330222	1234 main st	san francisco	ca	83923	2025-07-25 22:45:15.01821	2025-07-25 22:45:15.01821
7	Madison	Arnold	madison.arnold@preston.com	(817)392-3	80026 Alyssa Village	East Heather	AS	22940	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
9	John	Wyatt	john.wyatt@gutierrez.net	(605)945-4	90284 Harris Views	Briggsland	UT	80011	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
10	Elizabeth	Bautista	elizabeth.bautista@wilson.biz	8317911221	85167 Brown Wells	Carterborough	NH	17866	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
11	Jacob	Smith	jacob.smith@chambers.biz	(794)898-6	45073 Samuel Glen Suite 823	North Stephanie	WV	56488	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
12	Robert	Molina	robert.molina@davis.com	(926)526-7	449 Jefferson Prairie	Romerotown	IA	40326	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
13	Larry	Hester	larry.hester@taylor-garza.com	7702621386	0174 Lin Dale Apt. 279	Madisontown	OK	22525	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
14	Jennifer	Alvarez	jennifer.alvarez@walls-foster.net	673-332-39	14332 Karen Center	Dianamouth	MO	31606	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
15	Mark	Avery	mark.avery@harris.com	(487)291-1	7886 Anthony Plains	North Randall	VI	24831	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
16	Steven	Mccullough	steven.mccullough@wilson.org	9097400634	63100 Richardson Views	East Kathrynside	NM	84318	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
17	Brian	Davila	brian.davila@russell-blair.com	001-317-31	1230 Klein Spur Apt. 000	West Carlosview	AL	40896	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
18	Kevin	Obrien	kevin.obrien@moore.com	(299)751-2	1648 Vance Dale	Mccarthyborough	CA	06857	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
19	Tammy	Marquez	tammy.marquez@may-edwards.biz	001-548-57	37919 Aaron Spurs Suite 750	Smithport	IA	91734	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
21	Erica	Aguilar	erica.aguilar@bartlett.com	001-448-79	669 Thompson Greens	Roberttown	VT	03962	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
22	Dawn	Moore	dawn.moore@torres.com	+1-276-375	752 Melissa Junctions	West Brianna	MH	22775	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
23	Jennifer	Castro	jennifer.castro@hudson.net	001-972-50	4761 Abigail Isle Apt. 214	New Julianport	TX	45307	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
24	Katherine	Stewart	katherine.stewart@page.com	629.786.03	30645 Sandy Shore	Brianfort	OH	41666	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
25	April	Rodriguez	april.rodriguez@harris-jensen.com	(958)257-0	8650 Lindsey Ridge	Rodgersbury	MN	52234	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
26	Mary	Smith	mary.smith@brooks.biz	775.918.47	33272 Marc Ridges	Gibsonside	MO	95898	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
27	James	Brown	james.brown@moore-smith.com	311-280-65	00578 Kline Views	Martinezchester	MO	05325	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
28	Vincent	Robinson	vincent.robinson@simon.biz	425-463-73	69895 Bowman Courts	Port Marieport	VA	50783	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
29	Jill	Booth	jill.booth@weiss.org	539-970-76	7583 Swanson Landing Apt. 901	Wilsonstad	PA	92100	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
30	Daniel	Gray	daniel.gray@jones.com	771-989-04	414 Shawn Fort Suite 369	Thomasburgh	SC	38175	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
31	Jerry	Johnson	jerry.johnson@fields.net	(607)959-7	01843 Rhodes Ranch	Lake Jacob	NY	59371	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
32	Timothy	Jacobson	timothy.jacobson@hernandez.net	+1-960-303	911 Simmons Wells	South Bradley	MH	82574	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
33	Dana	Gallegos	dana.gallegos@bailey-edwards.biz	001-759-93	20616 Keith Island	Williamberg	OK	29226	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
34	Bobby	Mendoza	bobby.mendoza@baker.info	329.604.62	09730 Richard Plains Suite 232	West Travis	AS	40551	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
35	Sergio	Pitts	sergio.pitts@livingston-stone.org	915.934.35	2825 Tyler Row Apt. 723	East Amanda	GU	79155	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
36	Michael	Richardson	michael.richardson@hampton.com	+1-228-218	813 Joseph Shore	South Deborah	PR	44631	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
37	Harold	Strong	harold.strong@white.com	001-839-93	995 Farmer Terrace	Scottport	RI	68776	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
38	Ricardo	Jenkins	ricardo.jenkins@ramos-hayes.com	001-861-96	639 Calvin Oval Apt. 267	Port Joseph	GU	31660	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
39	Pamela	Mullen	pamela.mullen@shepard.com	739.866.99	54384 Daniel Walks Apt. 895	North Brucemouth	CT	44201	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
40	Alexander	Vega	alexander.vega@dougherty.biz	(980)731-9	549 Karina Way Apt. 089	Angelaview	WA	32178	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
41	Stephen	Singh	stephen.singh@blair.net	862.372.41	0253 Johnson Pine Suite 286	Robinsonfort	SC	15843	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
42	Catherine	Jackson	catherine.jackson@garcia.info	544-249-17	457 Diane Centers Suite 666	Hoffmanside	NJ	99689	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
43	Raymond	Wood	raymond.wood@saunders-walker.biz	001-593-74	9882 Smith Spurs Suite 743	Brownton	UT	94381	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
44	Jessica	Miller	jessica.miller@walker.com	(559)584-3	50581 Timothy Curve Suite 247	Hoganport	RI	45244	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
45	James	Small	james.small@todd.info	8192208889	8617 Jennings Mall Suite 035	South Benjamin	DC	30686	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
46	Allison	Ramirez	allison.ramirez@young.org	001-303-37	38122 Morales Turnpike	Mollyfurt	CA	46219	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
47	Devin	Shelton	devin.shelton@williams.com	761-357-67	300 Harris Port Suite 184	New Michael	VA	63716	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
48	Melissa	Morgan	melissa.morgan@webster.info	638-402-60	80294 Christopher Key Apt. 077	West Brianna	HI	31775	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
49	Elizabeth	Mayer	elizabeth.mayer@wright.org	402-914-73	1320 Adkins Squares Suite 630	New Katherineton	NJ	82666	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
50	John	Banks	john.banks@park.net	956.572.95	89956 Everett Throughway	New Michelle	AK	17613	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
51	Cameron	Fisher	cameron.fisher@perkins.net	+1-218-385	5350 Stevens Streets	North Wendy	KS	89792	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
52	Gina	Perkins	gina.perkins@myers.org	001-836-34	1543 Cheryl Parks	North David	MD	88204	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
53	Andrea	Clark	andrea.clark@richardson.com	(543)667-7	27230 Jennifer Locks	Jonathanview	MO	92497	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
54	James	Long	james.long@davis-fox.net	238.900.82	8649 Robin Walk	Tuckerfurt	PR	69383	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
55	Audrey	Stewart	audrey.stewart@martinez-terry.com	001-892-28	88637 Brooks Row Suite 318	New Angela	WV	45038	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
56	Andrew	Lester	andrew.lester@foley-johnson.com	(481)338-9	144 Kimberly Burg	Beckstad	DE	82469	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
57	Oscar	Alvarez	oscar.alvarez@wilson-harris.com	869-484-35	4826 Crystal Alley Suite 688	Brownburgh	FL	22251	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
58	Scott	Johnson	scott.johnson@ellis.com	(424)936-8	2905 Thomas Mountains	West Victoria	RI	72333	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
59	Mary	Shaw	mary.shaw@parks-nelson.net	978-872-94	26143 William Skyway Apt. 309	Matthewstad	DE	61347	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
60	Michael	Case	michael.case@reyes-lee.com	001-930-64	0672 Emily Mills Apt. 930	Maddenmouth	MH	53563	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
61	Robert	Hayden	robert.hayden@stevens-grant.org	539.505.02	2417 Daniel Trail Apt. 449	Tylerburgh	RI	55376	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
62	Caroline	Mckinney	caroline.mckinney@shepherd.com	673.917.11	092 Deborah Lights	Andersonport	RI	83039	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
63	Phyllis	Cole	phyllis.cole@mcdonald-howard.com	4919374096	80535 Michelle Underpass	Peckmouth	LA	55078	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
64	Eric	Norman	eric.norman@mcguire.com	+1-834-252	086 Underwood Land	Reyesville	CT	37187	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
65	Julie	Nichols	julie.nichols@atkins.net	910-399-85	27344 Sullivan Keys Suite 002	New Anne	AS	89888	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
66	Russell	Wilkerson	russell.wilkerson@moreno.com	(552)911-4	96248 Alicia Parks	East Virginia	IL	32670	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
67	Ashley	Johnston	ashley.johnston@hendrix.com	587-858-39	017 Gray Trace	East Sarahton	IN	25786	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
68	Ryan	Carroll	ryan.carroll@herrera-palmer.com	001-816-55	21448 Wood Plains	Brittneyshire	CT	43445	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
69	Ariel	Moore	ariel.moore@price-nguyen.com	966.221.17	769 Richard Common Apt. 260	West Tonishire	TN	72667	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
70	Lisa	Collier	lisa.collier@turner-garcia.com	829.708.88	256 Christopher Viaduct Suite 357	Hallview	HI	80854	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
71	Warren	Holden	warren.holden@williams.com	294-609-57	6693 Michelle Common	Burnsview	MI	12194	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
72	Maria	Conner	maria.conner@carter-greer.com	+1-937-894	68691 Owens Court Apt. 008	Thomasburgh	AS	00915	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
73	Lauren	Brewer	lauren.brewer@hendrix.com	925.330.05	01876 Mckenzie Station Apt. 491	Thomasborough	IN	57791	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
74	Janet	Kim	janet.kim@griffith.com	+1-583-812	4526 Faith Cliffs Apt. 231	Lake Gregoryfort	WV	08708	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
75	Michael	Scott	michael.scott@ray.com	(687)202-9	43070 Sanders Squares Suite 593	Hansenmouth	AS	73360	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
76	Scott	Smith	scott.smith@brown.com	(846)699-4	4925 Marc Ways Suite 334	Valdezfurt	WY	95049	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
77	Robert	Burch	robert.burch@gallagher.com	(501)634-0	423 John Harbor Suite 055	Port Jacqueline	NM	77673	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
78	Cindy	Wolfe	cindy.wolfe@white.com	(544)382-3	69904 Williams Glens Suite 594	Port Williamton	RI	75713	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
79	Alicia	Mcknight	alicia.mcknight@henry.com	001-299-75	368 Abigail Estates Apt. 465	South Jeffrey	MI	87822	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
80	Laura	Russell	laura.russell@johnson.net	(367)424-6	13944 Rivas Overpass Suite 137	Gabrielchester	MA	72206	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
81	Patricia	Delgado	patricia.delgado@valenzuela.com	(776)605-0	8047 David Cliff Apt. 060	Brewerberg	NV	20632	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
82	Nicole	Nichols	nicole.nichols@walker-brown.com	720-988-53	18378 Jeffrey Terrace	Bennettborough	OR	74542	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
83	Jeff	Taylor	jeff.taylor@williams.biz	(410)992-4	96532 Felicia Pike Apt. 207	South Richardchester	TX	27837	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
84	Steven	Cochran	steven.cochran@holmes.com	917-940-82	95255 Mendoza Mall	East Michaelchester	GU	37581	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
85	Ashley	Richmond	ashley.richmond@fisher.net	001-284-35	2222 Jamie Keys Suite 281	Lake Lisaland	TX	32835	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
86	Jennifer	Coleman	jennifer.coleman@hernandez-anderson.biz	833-527-31	021 Stefanie Branch	Davisside	WY	91661	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
87	Sarah	Simon	sarah.simon@huang.net	001-890-33	16415 Cruz Plains	West Barbara	ME	47845	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
88	Caitlin	Gomez	caitlin.gomez@ray.com	+1-868-608	55465 Williams Key Suite 003	Andersonfurt	MO	99423	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
89	Shelly	Nguyen	shelly.nguyen@bryant-brown.com	+1-759-604	656 Brandon Heights Suite 460	Savagemouth	AR	83874	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
90	Sarah	Brown	sarah.brown@smith.org	+1-214-597	323 Robin Station Suite 324	Port Amyland	AS	39988	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
91	Jennifer	Barnett	jennifer.barnett@ayala.com	(496)410-7	88551 Daniel Forge Apt. 586	Port Coleshire	VT	05584	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
92	Kimberly	Arnold	kimberly.arnold@roberts.com	+1-584-548	2974 Stephanie Springs Suite 162	South Melanie	AS	68931	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
93	Terri	Mcguire	terri.mcguire@buchanan.com	695-479-41	51019 Davis Ports	Lake Holly	KS	42051	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
94	Marcus	Patterson	marcus.patterson@allen.com	001-250-20	466 Gonzalez Expressway Apt. 948	Rodriguezbury	NV	87376	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
95	Jacqueline	Anderson	jacqueline.anderson@rivera.org	001-587-26	39099 Jason Throughway	Salinaston	CO	99628	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
96	Tina	Woodward	tina.woodward@gray.com	7716232895	73418 Jordan Ways Suite 709	Aliciamouth	GU	76798	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
97	Brandy	Ortiz	brandy.ortiz@bennett-martinez.com	(941)576-0	294 Castillo Estate Apt. 293	Donaldton	VA	57139	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
98	Matthew	Sanchez	matthew.sanchez@garrett.biz	850-564-48	246 Anderson Curve	Stevenhaven	IN	65331	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
99	Donald	Smith	donald.smith@moore-jones.com	515-437-30	984 Shannon Cape	East Julieland	CA	63378	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
100	Kathleen	Lloyd	kathleen.lloyd@garcia.com	(888)655-7	7206 Simmons Ranch	North Carrie	RI	74385	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
101	Kevin	Robertson	kevin.robertson@chavez.net	249.351.51	580 Ashley Trail	Michellestad	NE	98575	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
102	Julie	Smith	julie.smith@hughes-robinson.com	482.605.55	9082 Lisa Spur	Port Evelynport	FM	99716	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
103	Jared	Cuevas	jared.cuevas@mcdaniel.net	675.877.75	6738 Booth Wells	Lake Alicia	DE	95860	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
104	Keith	Hernandez	keith.hernandez@frank.biz	001-923-56	447 Marvin Turnpike	New Kelsey	VI	51370	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
105	Wendy	Mcdowell	wendy.mcdowell@rodriguez-bradley.biz	9856190769	9620 Willis Shoal Apt. 569	East Kathleen	OH	70052	2025-07-28 16:30:40.509139	2025-07-28 16:30:40.509139
106	Brett	Santiago	brett.santiago@smith-white.com	782.436.52	3462 Anita Pass	West Angela	AR	19769	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
107	Michael	Wilson	michael.wilson@burch.com	+1-566-522	4426 Kenneth Mission Suite 113	East Jasonport	GA	65149	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
108	Diane	Jones	diane.jones@perry.biz	+1-573-896	8895 Beasley Drive Suite 691	West Kara	VA	68978	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
109	Scott	Jones	scott.jones@carpenter-williams.com	961-994-33	0123 Bray Meadows Apt. 678	Port Timothymouth	VI	12924	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
110	Kimberly	Ponce	kimberly.ponce@lynch-lee.com	+1-549-221	4858 Margaret Place Suite 302	Port Steven	AZ	07492	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
111	Christopher	Taylor	christopher.taylor@lopez.org	2394800511	5686 Christina Gateway Suite 982	Katelynburgh	DC	76881	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
112	Bruce	Harris	bruce.harris@garcia.biz	+1-632-203	0588 Beard Field Apt. 282	Lauramouth	FM	66516	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
113	David	Ruiz	david.ruiz@gonzales.com	502.266.00	688 Douglas Shoal	West Elizabeth	PR	19471	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
114	Diamond	Olson	diamond.olson@stevens.com	(472)395-6	76580 Nelson River Apt. 770	South James	AS	57218	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
115	Heather	Wiggins	heather.wiggins@hall.com	(714)882-1	3588 Michael Forks	Lake Karenberg	MD	84281	2025-07-28 16:44:01.934265	2025-07-28 16:44:01.934265
116	Erika	Norton	erika.norton@bennett.com	(240)477-0	209 Thomas Branch	Beckview	ME	96227	2025-07-28 16:49:59.512251	2025-07-28 16:49:59.512251
117	Katherine	Tate	katherine.tate@valenzuela-mitchell.com	721-229-49	59807 Christine Knolls	East Sandra	MD	87542	2025-07-28 16:49:59.512251	2025-07-28 16:49:59.512251
118	Stephanie	Thompson	stephanie.thompson@reynolds-brown.com	001-251-90	858 Michael Underpass	Christophermouth	TX	17006	2025-07-28 16:49:59.512251	2025-07-28 16:49:59.512251
119	Andrew	Moore	andrew.moore@miller.com	378-604-78	06808 Snyder Pine	North Bryanport	NV	38247	2025-07-28 16:49:59.512251	2025-07-28 16:49:59.512251
120	Lauren	Hanson	lauren.hanson@green-perry.org	+1-306-954	62412 Brandon Green	Lake Timothyfort	AK	15908	2025-07-28 16:49:59.512251	2025-07-28 16:49:59.512251
121	Lori	Boone	lori.boone@thomas.com	429.819.72	95780 Yang Via	Deanview	AS	40530	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
122	Cody	Richmond	cody.richmond@nelson.org	645-602-11	81150 Erik Courts	East Paulberg	TN	46561	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
123	Trevor	Peters	trevor.peters@coleman.com	6844517917	443 Patricia Ridge	Gallagherville	HI	40735	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
124	Adrian	Krause	adrian.krause@diaz-mckinney.com	001-251-81	93893 Allen Mall	Davisville	FL	50368	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
125	Teresa	Haynes	teresa.haynes@hernandez-tanner.org	789.846.14	3141 Alexis Port	Danielport	IA	95399	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
126	Joel	Baker	joel.baker@adams-anderson.com	386.268.45	6213 Osborn Lights Suite 607	Walkerside	NH	24349	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
127	Rebecca	Francis	rebecca.francis@cochran-glover.org	001-401-81	885 Johnson Radial Apt. 960	Charlesside	DE	34724	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
128	Melissa	Warren	melissa.warren@reyes.biz	759.438.81	0900 Joshua Well Apt. 528	Jonesview	NH	07315	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
129	Lauren	Torres	lauren.torres@davis.net	9095258617	677 Grace Dam Apt. 144	Lake Aliciaborough	SC	43052	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
130	Deanna	Smith	deanna.smith@taylor-lawrence.com	278.764.48	05889 Kathryn Groves	Natashafort	HI	99389	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
131	Jessica	Brown	jessica.brown@rodriguez.org	001-703-66	47820 Mark Loaf Apt. 832	Breannamouth	DE	89152	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
132	Julia	Cruz	julia.cruz@collins.com	9125545734	2431 Justin Manor	Youngchester	MN	29564	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
133	Cassandra	Spencer	cassandra.spencer@romero.com	214-732-49	8916 Owen Crossroad Apt. 999	West Taylor	PA	58185	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
134	Christine	Terrell	christine.terrell@frank.com	5083679996	83531 Jordan Court	Port Alexanderchester	MD	46947	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
135	Cheryl	Perkins	cheryl.perkins@bowman-jenkins.com	+1-727-650	9784 Richard Harbors	Kimberlyville	AS	27293	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
136	Lauren	Velasquez	lauren.velasquez@davis.info	(415)839-2	8953 Long Passage	Melaniemouth	LA	54959	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
137	Justin	Fowler	justin.fowler@serrano.info	998.516.99	6272 Ball Road Suite 913	East Andrew	PR	06860	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
138	Luis	Byrd	luis.byrd@scott.org	505-258-90	89932 Tyler Crossing Apt. 393	Cobbmouth	ID	09758	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
139	Suzanne	Martin	suzanne.martin@stevens.com	880.813.44	4757 Erica Station Suite 134	Ginaburgh	MO	22314	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
140	Kelli	Richardson	kelli.richardson@mcclain.com	590.779.09	626 Jessica Lake	West Timothy	WV	03852	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
141	Jessica	Waters	jessica.waters@barry.com	323.599.59	8707 Nichols Mews Suite 510	Johnstontown	AS	08500	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
142	Thomas	Garcia	thomas.garcia@holland-reed.org	5924255950	124 Graham Vista	South Darrell	NV	98330	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
143	Robert	Diaz	robert.diaz@brandt-terrell.info	427-711-04	5744 Krista Curve	Millerborough	SC	23191	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
144	Steven	Howell	steven.howell@miller-leach.com	606-860-27	98181 Dodson Track Suite 678	Lake Sean	CO	34953	2025-07-28 22:19:16.074618	2025-07-28 22:19:16.074618
\.


--
-- Data for Name: orderitems; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.orderitems ("OrderItemId", "OrderId", "ProductId", "Quantity", "UnitPrice") FROM stdin;
1	1	1	1	1200.00
2	1	2	1	25.50
3	2	3	1	75.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.orders ("OrderId", "CustomerId", "OrderDate", "TotalAmount", "OrderStatus", "ShippingAddress", "ShippingCity", "ShippingState", "ShippingZipCode") FROM stdin;
1	1	2025-07-02 14:05:01.529123	1225.50	Processing	123 Main St	Anytown	CA	90210
2	2	2025-07-02 14:05:01.529123	75.00	Shipped	456 Oak Ave	Otherville	NY	10001
\.


--
-- Data for Name: productcategories; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.productcategories ("ProductId", "CategoryId") FROM stdin;
1	1
2	2
3	2
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.products ("ProductId", "ProductName", "Description", "Price", "StockQuantity", "DateAdded", "LastUpdated") FROM stdin;
1	Laptop Pro	High-performance laptop	1200.00	50	2025-07-02 14:05:01.529123	2025-07-02 14:05:01.529123
2	Wireless Mouse	Ergonomic wireless mouse	25.50	200	2025-07-02 14:05:01.529123	2025-07-02 14:05:01.529123
3	Mechanical Keyboard	RGB Mechanical keyboard	75.00	100	2025-07-02 14:05:01.529123	2025-07-02 14:05:01.529123
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: demo_retail; Owner: application
--

COPY demo_retail.reviews ("ReviewId", "ProductId", "CustomerId", "Rating", "Comment", "ReviewDate") FROM stdin;
1	1	1	5	Great laptop, very fast!	2025-07-02 14:05:01.529123
2	3	2	4	Solid keyboard, good feel.	2025-07-02 14:05:01.529123
\.


--
-- Name: categories_CategoryId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."categories_CategoryId_seq"', 2, true);


--
-- Name: customers_CustomerId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."customers_CustomerId_seq"', 144, true);


--
-- Name: orderitems_OrderItemId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."orderitems_OrderItemId_seq"', 3, true);


--
-- Name: orders_OrderId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."orders_OrderId_seq"', 2, true);


--
-- Name: products_ProductId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."products_ProductId_seq"', 3, true);


--
-- Name: reviews_ReviewId_seq; Type: SEQUENCE SET; Schema: demo_retail; Owner: application
--

SELECT pg_catalog.setval('demo_retail."reviews_ReviewId_seq"', 2, true);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY ("CategoryId");


--
-- Name: customers customers_Email_key; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.customers
    ADD CONSTRAINT "customers_Email_key" UNIQUE ("Email");


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY ("CustomerId");


--
-- Name: orderitems orderitems_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orderitems
    ADD CONSTRAINT orderitems_pkey PRIMARY KEY ("OrderItemId");


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY ("OrderId");


--
-- Name: productcategories productcategories_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.productcategories
    ADD CONSTRAINT productcategories_pkey PRIMARY KEY ("ProductId", "CategoryId");


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.products
    ADD CONSTRAINT products_pkey PRIMARY KEY ("ProductId");


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY ("ReviewId");


--
-- Name: customers trg_customers_updated_ات; Type: TRIGGER; Schema: demo_retail; Owner: application
--

CREATE OR REPLACE FUNCTION demo_retail.update_customers_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $$
BEGIN
    NEW."LastUpdated" = NOW();
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION demo_retail.update_products_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $$
BEGIN
    NEW."LastUpdated" = NOW();
    RETURN NEW;
END;
$$;



CREATE TRIGGER "trg_customers_updated_ات" BEFORE UPDATE ON demo_retail.customers FOR EACH ROW EXECUTE FUNCTION demo_retail.update_customers_updated_at();


--
-- Name: products trg_products_updated_at; Type: TRIGGER; Schema: demo_retail; Owner: application
--

CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON demo_retail.products FOR EACH ROW EXECUTE FUNCTION demo_retail.update_products_updated_at();


--
-- Name: orderitems orderitems_OrderId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orderitems
    ADD CONSTRAINT "orderitems_OrderId_fkey" FOREIGN KEY ("OrderId") REFERENCES demo_retail.orders("OrderId");


--
-- Name: orderitems orderitems_ProductId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orderitems
    ADD CONSTRAINT "orderitems_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES demo_retail.products("ProductId");


--
-- Name: orders orders_CustomerId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.orders
    ADD CONSTRAINT "orders_CustomerId_fkey" FOREIGN KEY ("CustomerId") REFERENCES demo_retail.customers("CustomerId");


--
-- Name: productcategories productcategories_CategoryId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.productcategories
    ADD CONSTRAINT "productcategories_CategoryId_fkey" FOREIGN KEY ("CategoryId") REFERENCES demo_retail.categories("CategoryId");


--
-- Name: productcategories productcategories_ProductId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.productcategories
    ADD CONSTRAINT "productcategories_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES demo_retail.products("ProductId");


--
-- Name: reviews reviews_CustomerId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.reviews
    ADD CONSTRAINT "reviews_CustomerId_fkey" FOREIGN KEY ("CustomerId") REFERENCES demo_retail.customers("CustomerId");


--
-- Name: reviews reviews_ProductId_fkey; Type: FK CONSTRAINT; Schema: demo_retail; Owner: application
--

ALTER TABLE ONLY demo_retail.reviews
    ADD CONSTRAINT "reviews_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES demo_retail.products("ProductId");


--
-- Name: SCHEMA demo_retail; Type: ACL; Schema: -; Owner: application
--

GRANT ALL ON SCHEMA demo_retail TO application;


--
-- Name: TABLE categories; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.categories TO application;


--
-- Name: SEQUENCE "categories_CategoryId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."categories_CategoryId_seq" TO application;


--
-- Name: TABLE customers; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.customers TO application;


--
-- Name: SEQUENCE "customers_CustomerId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."customers_CustomerId_seq" TO application;


--
-- Name: TABLE orderitems; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.orderitems TO application;


--
-- Name: SEQUENCE "orderitems_OrderItemId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."orderitems_OrderItemId_seq" TO application;


--
-- Name: TABLE orders; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.orders TO application;


--
-- Name: SEQUENCE "orders_OrderId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."orders_OrderId_seq" TO application;


--
-- Name: TABLE productcategories; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.productcategories TO application;


--
-- Name: TABLE products; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.products TO application;


--
-- Name: SEQUENCE "products_ProductId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."products_ProductId_seq" TO application;


--
-- Name: TABLE reviews; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE demo_retail.reviews TO application;


--
-- Name: SEQUENCE "reviews_ReviewId_seq"; Type: ACL; Schema: demo_retail; Owner: application
--

GRANT SELECT,USAGE ON SEQUENCE demo_retail."reviews_ReviewId_seq" TO application;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: demo_retail; Owner: application
--

ALTER DEFAULT PRIVILEGES FOR ROLE application IN SCHEMA demo_retail GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO application;


--
-- applicationQL database dump complete
--

