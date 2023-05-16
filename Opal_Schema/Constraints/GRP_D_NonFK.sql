ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT C_GRP_D_ALDC
  CHECK (is_leaf=1 and (dim_lev_code is not null or cond_id is not null) or
   is_leaf <>1 and dim_lev_code is null and cond_id is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT C_GRP_D_DC
  CHECK (dim_lev_code is null or cond_id is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT C_GRP_D_T
  CHECK (nvl(grp_type, '@')='D')
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GRP_D ADD (
  CONSTRAINT U_GRP_D
  UNIQUE (GRP_ID)
  ENABLE VALIDATE);