-- 
-- CATEGORIES  (Table Foreign Keys)
-- 
-- Dependencies: 
--    AREAS (Table)
ALTER TABLE OPAL_FRA.CATEGORIES ADD (
  CONSTRAINT R_CATEGORIES#A 
  FOREIGN KEY (AREA_ID) 
  REFERENCES OPAL_FRA.AREAS (ID)
  ON DELETE CASCADE
  ENABLE VALIDATE);