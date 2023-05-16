-- 
-- GRP_P  (Table Foreign Keys)
-- 
-- Dependencies: 
--    FUNC_ROW_ (Table)
--    GROUPS (Table)
ALTER TABLE OPAL_FRA.GRP_P ADD (
  CONSTRAINT R_GRP_P_F 
  FOREIGN KEY (FUNC_ID) 
  REFERENCES OPAL_FRA.FUNC_ROW_ (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_P ADD (
  CONSTRAINT R_GRP_P_G 
  FOREIGN KEY (GRP_ID, GRP_TYPE, IS_LEAF) 
  REFERENCES OPAL_FRA.GROUPS (ID, GRP_TYPE, IS_LEAF)
  ON DELETE CASCADE
  ENABLE VALIDATE);