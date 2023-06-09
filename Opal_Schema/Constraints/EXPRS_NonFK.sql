ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT C_EXPRS_I
  CHECK (is_leaf is null or is_leaf in (0,1))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT C_EXPRS_S
  CHECK (op_sign in ('+','-','*','/') and nvl(is_leaf,0)=0  or is_leaf=1 and op_sign is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT P_EXPRS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT U_EXPRS_DESCR
  UNIQUE (DESCR)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT U_EXPRS_LEAF
  UNIQUE (ID, IS_LEAF)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.EXPRS ADD (
  CONSTRAINT U_EXPRS_PO
  UNIQUE (PARENT_ID, ORDNO)
  ENABLE VALIDATE);