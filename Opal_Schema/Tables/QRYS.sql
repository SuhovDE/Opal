--
-- QRYS  (Table) 
--
--  Dependencies: 
--   QUERY_TYPES (Table)
--
--   Row Count: 2047
CREATE TABLE OPAL_FRA.QRYS
(
  QRY_TYPE    INTEGER                           NOT NULL,
  CUBE_ID     INTEGER                           NOT NULL,
  WHERE_ID    INTEGER,
  HAVING_ID   INTEGER,
  ABBR        VARCHAR2(100 CHAR)                NOT NULL,
  SHORT       VARCHAR2(1000 CHAR),
  PREDEFINED  CHAR(1 BYTE)                      DEFAULT 'N',
  SETTINGS    CLOB                              DEFAULT empty_clob(),
  CR_USER     VARCHAR2(30 CHAR)                 NOT NULL,
  UP_USER     VARCHAR2(30 CHAR),
  EX_USER     VARCHAR2(30 CHAR),
  CR_TERM     VARCHAR2(255 CHAR)                NOT NULL,
  UP_TERM     VARCHAR2(255 CHAR),
  EX_TERM     VARCHAR2(255 CHAR),
  CR_TIME     DATE                              NOT NULL,
  UP_TIME     DATE,
  EX_TIME     DATE,
  DURATION    NUMBER,
  RECCOUNT    INTEGER,
  CR_HOST     VARCHAR2(30 CHAR)                 NOT NULL,
  UP_HOST     VARCHAR2(30 CHAR),
  EX_HOST     VARCHAR2(30 CHAR),
  TMP         CHAR(1 BYTE),
  VERSION_NO  INTEGER,
  TMP_QRY_ID  INTEGER,
  IS_PRIVATE  CHAR(1 BYTE)                      DEFAULT 'P'                   NOT NULL,
  LAYOUT      CLOB,
  ORG_ID      INTEGER                           NOT NULL,
  ID          INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY ( START WITH 35640 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP NOSCALE) NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

COMMENT ON TABLE OPAL_FRA.QRYS IS 'Description of system queries';

COMMENT ON COLUMN OPAL_FRA.QRYS.QRY_TYPE IS 'Ref to query types';

COMMENT ON COLUMN OPAL_FRA.QRYS.CUBE_ID IS 'Ref to data cube, over which the query is done';

COMMENT ON COLUMN OPAL_FRA.QRYS.WHERE_ID IS 'ref to WHERE condition of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.HAVING_ID IS 'ref to HAVING condition of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.ABBR IS 'Code of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.SHORT IS 'Short description of the query, only to show';

COMMENT ON COLUMN OPAL_FRA.QRYS.PREDEFINED IS 'Y - predefined query, N - no.';

COMMENT ON COLUMN OPAL_FRA.QRYS.CR_USER IS 'The Oracle user that has created this query';

COMMENT ON COLUMN OPAL_FRA.QRYS.UP_USER IS 'The Oracle user that has updated this query last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.EX_USER IS 'The Oracle user that has executed this query last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.CR_TERM IS 'The OS user that has created this query';

COMMENT ON COLUMN OPAL_FRA.QRYS.UP_TERM IS 'The OS user that has updated this query last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.EX_TERM IS 'The OS user that has executed this query last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.CR_TIME IS 'The date-time of the creation of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.UP_TIME IS 'The date-time of the last update of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.EX_TIME IS 'The date-time of the last execution of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.DURATION IS 'The duration of the last execution of the query, sec';

COMMENT ON COLUMN OPAL_FRA.QRYS.RECCOUNT IS 'The record count on the last execution of the query';

COMMENT ON COLUMN OPAL_FRA.QRYS.CR_HOST IS 'The machine from that this query was created';

COMMENT ON COLUMN OPAL_FRA.QRYS.UP_HOST IS 'The machine from that this query was updated last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.EX_HOST IS 'The machine from that this query was executed last time';

COMMENT ON COLUMN OPAL_FRA.QRYS.TMP IS 'Not null - query is temporary';

COMMENT ON COLUMN OPAL_FRA.QRYS.VERSION_NO IS 'Version number of the basic query';

COMMENT ON COLUMN OPAL_FRA.QRYS.TMP_QRY_ID IS 'TMP query reference to the basic query';

COMMENT ON COLUMN OPAL_FRA.QRYS.IS_PRIVATE IS 'Query is accessible to everybody, except of CR_USER: P - Public (no restrictions); R - only Read; N - No access';