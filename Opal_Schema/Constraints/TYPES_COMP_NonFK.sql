ALTER TABLE OPAL_FRA.TYPES_COMP ADD (
  CONSTRAINT P_TYPES_COMP
  PRIMARY KEY
  (TYPE_ID, COMP_TYPE_ID)
  ENABLE VALIDATE);