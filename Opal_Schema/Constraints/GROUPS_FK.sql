-- 
-- GROUPS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    DIMS (Table)
--    DOMAINS (Table)
--    ATTR_TYPES (Table)
ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT R_GROUPS_D 
  FOREIGN KEY (DIM_ID) 
  REFERENCES OPAL_FRA.DIMS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT R_GROUPS_DOM 
  FOREIGN KEY (DOM_ID) 
  REFERENCES OPAL_FRA.DOMAINS (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.GROUPS ADD (
  CONSTRAINT R_GROUPS_T 
  FOREIGN KEY (TYPE_ID) 
  REFERENCES OPAL_FRA.ATTR_TYPES (ID)
  ENABLE VALIDATE);