ALTER TABLE OPAL_FRA.FUNC_ROW_DB ADD (
  CONSTRAINT P_FUNC_ROW_DB
  PRIMARY KEY
  (ID, DB_TYPE)
  ENABLE VALIDATE);