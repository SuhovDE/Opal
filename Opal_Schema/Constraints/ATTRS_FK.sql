-- 
-- ATTRS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    CATEGORIES (Table)
--    AREAS (Table)
--    DIM_LEVELS (Table)
--    EXPRS (Table)
--    ATTRS (Table)
--    ATTR_TYPES (Table)
--    ATTR_TYPES (Table)
ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS#C 
  FOREIGN KEY (AREA_ID, CATEGORY_ID) 
  REFERENCES OPAL_FRA.CATEGORIES (AREA_ID, ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_A 
  FOREIGN KEY (AREA_ID) 
  REFERENCES OPAL_FRA.AREAS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_D 
  FOREIGN KEY (DIM_LEV_ID) 
  REFERENCES OPAL_FRA.DIM_LEVELS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_E 
  FOREIGN KEY (EXPR_ID) 
  REFERENCES OPAL_FRA.EXPRS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_P 
  FOREIGN KEY (PARENT_ID) 
  REFERENCES OPAL_FRA.ATTRS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_STORAGE 
  FOREIGN KEY (STORAGE_TYPE) 
  REFERENCES OPAL_FRA.ATTR_TYPES (ID)
  DEFERRABLE INITIALLY DEFERRED
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT R_ATTRS_T 
  FOREIGN KEY (ATTR_TYPE) 
  REFERENCES OPAL_FRA.ATTR_TYPES (ID)
  DEFERRABLE INITIALLY DEFERRED
  ENABLE VALIDATE);