-- 
-- DATASETS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    QRYS (Table)
ALTER TABLE OPAL_FRA.DATASETS ADD (
  CONSTRAINT R_DATASETS#Q 
  FOREIGN KEY (QRY_ID) 
  REFERENCES OPAL_FRA.QRYS (ID)
  ON DELETE CASCADE
  ENABLE VALIDATE);