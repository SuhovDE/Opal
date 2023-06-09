--
-- TEST_QUERYOBJ  (Table) 
--
--  Dependencies: 
--   CONDELEMLIST (Type)
--   CONDEXPRLIST (Type)
--   QRYSELLIST (Type)
--   QUERYOBJ (Type)
--   STANDARD (Package)
--
--   Row Count: 1
CREATE TABLE OPAL_FRA.TEST_QUERYOBJ OF OPAL_FRA.QUERYOBJ 
NESTED TABLE SELECTION STORE AS TEST_QUERYOBJ_SEL,
NESTED TABLE FILTERCONDS STORE AS TEST_QUERYOBJ_FC,
NESTED TABLE FILTERELEMS STORE AS TEST_QUERYOBJ_FE
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