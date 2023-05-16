-- 
-- GRP_TREE  (Table Foreign Keys)
-- 
-- Dependencies: 
--    GROUPS (Table)
--    GROUPS (Table)
ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT R_GRP_TREE_I 
  FOREIGN KEY (ID) 
  REFERENCES OPAL_FRA.GROUPS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_TREE ADD (
  CONSTRAINT R_GRP_TREE_P 
  FOREIGN KEY (PARENT_ID) 
  REFERENCES OPAL_FRA.GROUPS (ID)
  ENABLE VALIDATE);