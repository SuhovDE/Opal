ALTER TABLE OPAL_FRA.OBJ_COL_NAMES ADD (
  CONSTRAINT P_OBJ_COL_NAMES
  PRIMARY KEY
  (COL_ID, ROW_ID, LANG_ID)
  ENABLE VALIDATE);