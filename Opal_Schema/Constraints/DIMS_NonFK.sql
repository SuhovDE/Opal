ALTER TABLE OPAL_FRA.DIMS ADD (
  CONSTRAINT P_DIMS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.DIMS ADD (
  CONSTRAINT U_DIMS_DD
  UNIQUE (ID, DOM_ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.DIMS ADD (
  CONSTRAINT U_DIMS_S
  UNIQUE (SCODE)
  ENABLE VALIDATE);