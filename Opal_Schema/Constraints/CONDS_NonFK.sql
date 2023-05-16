ALTER TABLE OPAL_FRA.CONDS ADD (
  CONSTRAINT C_CONDS_GH
  CHECK (nvl(gh, '@') in ('G','H','C'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.CONDS ADD (
  CONSTRAINT C_CONDS_I
  CHECK (is_leaf in (1))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.CONDS ADD (
  CONSTRAINT C_CONDS_S
  CHECK (op_sign in ('AND','OR', 'CASE', 'NOT AND', 'NOT OR') and nvl(is_leaf, 0)<>1  or op_sign is null and nvl(is_leaf,0)=1)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.CONDS ADD (
  CONSTRAINT P_CONDS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.CONDS ADD (
  CONSTRAINT U_CONDS_LEAF
  UNIQUE (ID, IS_LEAF)
  ENABLE VALIDATE);