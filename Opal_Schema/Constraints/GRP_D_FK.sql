-- 
-- GRP_D  (Table Foreign Keys)
-- 
-- Dependencies: 
--    CONDS (Table)
--    DIM_LEVELS (Table)
--    GROUPS (Table)
ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT R_GRP_D_COND 
  FOREIGN KEY (COND_ID, IS_LEAF) 
  REFERENCES OPAL_FRA.CONDS (ID, IS_LEAF)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT R_GRP_D_D 
  FOREIGN KEY (DIM_LEV_ID) 
  REFERENCES OPAL_FRA.DIM_LEVELS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT R_GRP_D_G 
  FOREIGN KEY (GRP_ID, GRP_TYPE, IS_LEAF) 
  REFERENCES OPAL_FRA.GROUPS (ID, GRP_TYPE, IS_LEAF)
  ON DELETE CASCADE
  ENABLE VALIDATE);