ALTER TABLE OPAL_FRA.DATASETS ADD (
  CONSTRAINT P_DATASETS
  PRIMARY KEY
  (QRY_ID, RNG)
  ENABLE VALIDATE);