--
-- QRYS_BAK  (Table) 
--
--   Row Count: 2047
CREATE TABLE OPAL_FRA.QRYS_BAK
(
  ID          INTEGER,
  QRY_TYPE    INTEGER                           NOT NULL,
  CUBE_ID     INTEGER                           NOT NULL,
  WHERE_ID    INTEGER,
  HAVING_ID   INTEGER,
  ABBR        VARCHAR2(100 CHAR)                NOT NULL,
  SHORT       VARCHAR2(1000 CHAR),
  PREDEFINED  CHAR(1 BYTE),
  SETTINGS    CLOB,
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
  IS_PRIVATE  CHAR(1 BYTE)                      NOT NULL,
  LAYOUT      CLOB,
  ORG_ID      INTEGER                           NOT NULL
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