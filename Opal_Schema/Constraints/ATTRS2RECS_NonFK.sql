ALTER TABLE OPAL_FRA.ATTRS2RECS ADD (
  CONSTRAINT P_ATTRS2RECS
  PRIMARY KEY
  (ATTR_ID, ELEM_REC_ID)
  ENABLE VALIDATE);