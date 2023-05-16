ALTER TABLE OPAL_FRA.FOLDERS ADD (
  CONSTRAINT C_FOLDERS#PID
  CHECK (pid<>id)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.FOLDERS ADD (
  CONSTRAINT C_FORDERS_ROOT
  CHECK (pid is null and scode='ROOT' or pid is not null and nvl(scode, '!')<>'ROOT')
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.FOLDERS ADD (
  CONSTRAINT P_FOLDERS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.FOLDERS ADD (
  CONSTRAINT U_FOLDERS_PN
  UNIQUE (PID, ABBR)
  ENABLE VALIDATE);