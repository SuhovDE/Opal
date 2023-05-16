ALTER TABLE OPAL_FRA.ATTRS2CUBES ADD (
  CONSTRAINT C_ATTRS2CUBES_SHOW
  CHECK (nvl(show, '@') in ('K','V','N'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS2CUBES ADD (
  CONSTRAINT U_ATTRS2CUBES
  PRIMARY KEY
  (ATTR_ID, CUBE_ID)
  ENABLE VALIDATE);