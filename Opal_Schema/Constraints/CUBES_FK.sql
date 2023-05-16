-- 
-- CUBES  (Table Foreign Keys)
-- 
-- Dependencies: 
--    CUBES (Table)
ALTER TABLE OPAL_FRA.CUBES ADD (
  CONSTRAINT R_CUBES_P 
  FOREIGN KEY (PARENT_ID) 
  REFERENCES OPAL_FRA.CUBES (ID)
  DEFERRABLE INITIALLY DEFERRED
  ENABLE VALIDATE);