-- 
-- OBJ_COL_NAMES  (Table Foreign Keys)
-- 
-- Dependencies: 
--    OBJ_COL_IDS (Table)
--    LANGUAGES (Table)
ALTER TABLE OPAL_FRA.OBJ_COL_NAMES ADD (
  CONSTRAINT R_OBJ_COL_TXT_C 
  FOREIGN KEY (COL_ID) 
  REFERENCES OPAL_FRA.OBJ_COL_IDS (COL_ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OBJ_COL_NAMES ADD (
  CONSTRAINT R_OBJ_COL_TXT_L 
  FOREIGN KEY (LANG_ID) 
  REFERENCES OPAL_FRA.LANGUAGES (ID)
  ENABLE VALIDATE);