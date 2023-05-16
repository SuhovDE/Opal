-- 
-- OBJ_COL_IDS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    OBJ_IDS (Table)
ALTER TABLE OPAL_FRA.OBJ_COL_IDS ADD (
  CONSTRAINT R_OBJ_COL_IDS_O 
  FOREIGN KEY (OBJ_ID) 
  REFERENCES OPAL_FRA.OBJ_IDS (ID)
  ENABLE VALIDATE);