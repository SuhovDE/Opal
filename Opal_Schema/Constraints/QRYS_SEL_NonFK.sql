ALTER TABLE OPAL_FRA.QRYS_SEL ADD (
  CONSTRAINT C_QRYS_SEL_GRP
  CHECK (grp_id is not null and grp_lev_ordno is not null or   grp_id is null and grp_lev_ordno is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QRYS_SEL ADD (
  CONSTRAINT P_QRY_SEL
  PRIMARY KEY
  (QRY_ID, ORDNO)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.QRYS_SEL ADD (
  CONSTRAINT U_QRY_SEL
  UNIQUE (QRY_ID, ATTR_ID, DIM_LEV_ID, FUNC_GRP_ID, GRP_ID, GRP_LEV_ORDNO)
  ENABLE VALIDATE);