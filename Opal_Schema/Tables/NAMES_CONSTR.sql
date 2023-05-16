--
-- NAMES_CONSTR  (Table) 
--
--   Row Count: 7
CREATE TABLE OPAL_FRA.NAMES_CONSTR
(
  CONSTRAINT_NAME  VARCHAR2(30 CHAR),
  TABLE_NAME       VARCHAR2(30 CHAR),
  CO               NUMBER,
  CBODY            CLOB
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