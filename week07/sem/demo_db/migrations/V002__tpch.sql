create schema tpch;

CREATE TABLE tpch.customer
(C_CUSTKEY INT,
 C_NAME VARCHAR(25),
 C_ADDRESS VARCHAR(40),
 C_NATIONKEY INTEGER,
 C_PHONE CHAR(15),
 C_ACCTBAL DECIMAL(15,2),
 C_MKTSEGMENT CHAR(10),
 C_COMMENT VARCHAR(117));

CREATE TABLE tpch.lineitem
(L_ORDERKEY BIGINT,
 L_PARTKEY INT,
 L_SUPPKEY INT,
 L_LINENUMBER INTEGER,
 L_QUANTITY DECIMAL(15,2),
 L_EXTENDEDPRICE DECIMAL(15,2),
 L_DISCOUNT DECIMAL(15,2),
 L_TAX DECIMAL(15,2),
 L_RETURNFLAG CHAR(1),
 L_LINESTATUS CHAR(1),
 L_SHIPDATE DATE,
 L_COMMITDATE DATE,
 L_RECEIPTDATE DATE,
 L_SHIPINSTRUCT CHAR(25),
 L_SHIPMODE CHAR(10),
 L_COMMENT VARCHAR(44));

CREATE TABLE tpch.nation
(N_NATIONKEY INTEGER,
 N_NAME CHAR(25),
 N_REGIONKEY INTEGER,
 N_COMMENT VARCHAR(152));

CREATE TABLE tpch.orders
(O_ORDERKEY BIGINT,
 O_CUSTKEY INT,
 O_ORDERSTATUS CHAR(1),
 O_TOTALPRICE DECIMAL(15,2),
 O_ORDERDATE DATE,
 O_ORDERPRIORITY CHAR(15),
 O_CLERK  CHAR(15),
 O_SHIPPRIORITY INTEGER,
 O_COMMENT VARCHAR(79));

CREATE TABLE tpch.part
(P_PARTKEY INT,
 P_NAME VARCHAR(55),
 P_MFGR CHAR(25),
 P_BRAND CHAR(10),
 P_TYPE VARCHAR(25),
 P_SIZE INTEGER,
 P_CONTAINER CHAR(10),
 P_RETAILPRICE DECIMAL(15,2),
 P_COMMENT VARCHAR(23));

CREATE TABLE tpch.partsupp
(PS_PARTKEY INT,
 PS_SUPPKEY INT,
 PS_AVAILQTY INTEGER,
 PS_SUPPLYCOST DECIMAL(15,2),
 PS_COMMENT VARCHAR(199));

CREATE TABLE tpch.region
(R_REGIONKEY INTEGER,
 R_NAME CHAR(25),
 R_COMMENT VARCHAR(152));

CREATE TABLE tpch.supplier
(S_SUPPKEY INT,
 S_NAME CHAR(25),
 S_ADDRESS VARCHAR(40),
 S_NATIONKEY INTEGER,
 S_PHONE CHAR(15),
 S_ACCTBAL DECIMAL(15,2),
 S_COMMENT VARCHAR(101));

copy tpch.customer from  '/var/lib/postgresql/tpch_data/customer_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.lineitem from  '/var/lib/postgresql/tpch_data/lineitem_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.nation from  '/var/lib/postgresql/tpch_data/nation_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.orders from  '/var/lib/postgresql/tpch_data/orders_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.part from  '/var/lib/postgresql/tpch_data/part_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.partsupp from  '/var/lib/postgresql/tpch_data/partsupp_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.region from  '/var/lib/postgresql/tpch_data/region_new.csv' WITH (FORMAT csv, DELIMITER '|');
copy tpch.supplier from  '/var/lib/postgresql/tpch_data/supplier_new.csv' WITH (FORMAT csv, DELIMITER '|');