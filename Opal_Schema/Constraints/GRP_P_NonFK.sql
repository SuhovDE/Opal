ALTER TABLE OPAL_FRA.GRP_P ADD (
  CONSTRAINT C_GRP_P_T
  CHECK (nvl(grp_type, '@')='P')
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_P ADD (
  CONSTRAINT U_GRP_P
  UNIQUE (GRP_ID)
  ENABLE VALIDATE);