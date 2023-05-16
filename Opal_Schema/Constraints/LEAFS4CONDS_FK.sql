-- 
-- LEAFS4CONDS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    FUNC_GRP (Table)
--    GROUPS (Table)
--    ATTRS (Table)
--    FUNC_ROW_ (Table)
--    CONDS (Table)
--    OPS (Table)
--    ATTRS (Table)
--    FUNC_ROW_ (Table)
--    FUNC_GRP (Table)
ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAF4CONDS_RF 
  FOREIGN KEY (LEFT_FUNC_GRP_ID) 
  REFERENCES OPAL_FRA.FUNC_GRP (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_G 
  FOREIGN KEY (GRP_ID) 
  REFERENCES OPAL_FRA.GROUPS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_LA 
  FOREIGN KEY (LEFT_ATTR_ID) 
  REFERENCES OPAL_FRA.ATTRS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_LFR 
  FOREIGN KEY (LEFT_FUNC_ROW_ID) 
  REFERENCES OPAL_FRA.FUNC_ROW_ (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_LI 
  FOREIGN KEY (LEAF_ID, IS_LEAF) 
  REFERENCES OPAL_FRA.CONDS (ID, IS_LEAF)
  ON DELETE CASCADE
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_O 
  FOREIGN KEY (OP_SIGN, OP_KIND) 
  REFERENCES OPAL_FRA.OPS (OP_SIGN, OP_KIND)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_RA 
  FOREIGN KEY (RIGHT_ATTR_ID) 
  REFERENCES OPAL_FRA.ATTRS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEAFS4CONDS_RFR 
  FOREIGN KEY (RIGHT_FUNC_ROW_ID) 
  REFERENCES OPAL_FRA.FUNC_ROW_ (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.LEAFS4CONDS ADD (
  CONSTRAINT R_LEASF4CONDS_LF 
  FOREIGN KEY (RIGHT_FUNC_GRP_ID) 
  REFERENCES OPAL_FRA.FUNC_GRP (ID)
  ENABLE VALIDATE);