-- 
-- FUNC_ROW_  (Table Foreign Keys)
-- 
-- Dependencies: 
--    ATTR_TYPES (Table)
--    ATTR_TYPES (Table)
ALTER TABLE OPAL_FRA.FUNC_ROW_ ADD (
  CONSTRAINT R_FUNC_ROW_PT 
  FOREIGN KEY (PAR_TYPE) 
  REFERENCES OPAL_FRA.ATTR_TYPES (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.FUNC_ROW_ ADD (
  CONSTRAINT R_FUNC_ROW_RT 
  FOREIGN KEY (RET_TYPE) 
  REFERENCES OPAL_FRA.ATTR_TYPES (ID)
  ENABLE VALIDATE);