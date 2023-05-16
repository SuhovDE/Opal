--
-- TEST_INT_GRP  (Table) 
--
--  Dependencies: 
--   COND_NODES (Type)
--   INT_GRP_OBJ (Type)
--   STANDARD (Package)
--
--   Row Count: 228
CREATE TABLE OPAL_FRA.TEST_INT_GRP OF OPAL_FRA.INT_GRP_OBJ 
NESTED TABLE NODES STORE AS TEST_INT_GRP_NODES
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