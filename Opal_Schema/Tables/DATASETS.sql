--
-- DATASETS  (Table) 
--
--  Dependencies: 
--   QRYS (Table)
--
--   Row Count: 19
CREATE TABLE OPAL_FRA.DATASETS
(
  QRY_ID    INTEGER,
  RNG       NUMBER(1),
  QRY       CLOB,
  LVL_NAME  VARCHAR2(100 CHAR),
  TABNAME   VARCHAR2(30 CHAR)
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