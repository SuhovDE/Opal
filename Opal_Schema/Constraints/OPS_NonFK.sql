ALTER TABLE OPAL_FRA.OPS ADD (
  CONSTRAINT C_OPS_KIND
  CHECK (nvl(op_kind, '@') in ('C','L','E'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OPS ADD (
  CONSTRAINT C_OPS_SHOW
  CHECK (nvl(show, 'Y') in ('Y','N'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OPS ADD (
  CONSTRAINT PK_OPS
  PRIMARY KEY
  (OP_SIGN)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OPS ADD (
  CONSTRAINT U_OPS_OT
  UNIQUE (OP_SIGN, OP_KIND)
  ENABLE VALIDATE);