--
-- TEST_QRY  (Table) 
--
--   Row Count: 1
CREATE TABLE OPAL_FRA.TEST_QRY
(
  QRY  CLOB,
  ID   INTEGER
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