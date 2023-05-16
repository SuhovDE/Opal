ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT C_LEAFS4CONDS_G
  CHECK (op_sign in ('IN','NOT IN') and (grp_id < 1000000 or const is not null)
   or  op_sign not in ('IN','NOT IN') and (grp_id is null or grp_id>=1000000))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT C_LEAFS4CONDS_I
  CHECK (nvl(is_leaf,0)=1)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT C_LEAFS4CONDS_IC
  CHECK (is_compare='C')
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT C_LEAFS4CONDS_RF
  CHECK (
 grp_id is not null and const is null and right_attr_id is null or
 const is null and right_attr_id is not null or
 const is not null and right_attr_id is null or
 instr(op_sign, 'NULL')>0 and const is not null and right_attr_id is null)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT U_LEAF4CONDS
  PRIMARY KEY
  (LEAF_ID)
  ENABLE VALIDATE);