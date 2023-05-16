--
-- FUNC_ROW_DB  (Table) 
--
--  Dependencies: 
--   FUNC_ROW_ (Table)
--
--   Row Count: 62
CREATE TABLE OPAL_FRA.FUNC_ROW_DB
(
  ID       VARCHAR2(30 CHAR),
  DB_TYPE  VARCHAR2(9 CHAR),
  SUBST    VARCHAR2(255 CHAR),
  READY    CHAR(1 CHAR)
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