--
-- QRYS_TST  (Table) 
--
--   Row Count: 164
CREATE TABLE OPAL_FRA.QRYS_TST
(
  ID          INTEGER,
  QRY_TYPE    INTEGER                           NOT NULL,
  CUBE_ID     INTEGER                           NOT NULL,
  WHERE_ID    INTEGER,
  HAVING_ID   INTEGER,
  ABBR        VARCHAR2(20 CHAR)                 NOT NULL,
  SHORT       VARCHAR2(256 CHAR),
  PREDEFINED  CHAR(1 BYTE),
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
  EX_HOST     VARCHAR2(30 CHAR)
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