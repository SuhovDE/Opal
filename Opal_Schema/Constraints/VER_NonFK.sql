ALTER TABLE OPAL_FRA.VER ADD (
  CONSTRAINT C_FINISHED_F
  CHECK (nullif(finished, 'N') is null)
  ENABLE VALIDATE);