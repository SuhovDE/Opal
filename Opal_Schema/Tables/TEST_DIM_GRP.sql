--
-- TEST_DIM_GRP  (Table) 
--
--  Dependencies: 
--   DIM_GRP_OBJ (Type)
--   TREE_NODES (Type)
--   STANDARD (Package)
--
--   Row Count: 170
CREATE TABLE OPAL_FRA.TEST_DIM_GRP OF OPAL_FRA.DIM_GRP_OBJ 
NESTED TABLE NODES STORE AS TEST_DIM_GRP_NODES
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