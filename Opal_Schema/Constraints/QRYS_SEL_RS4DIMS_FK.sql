-- 
-- QRYS_SEL_RS4DIMS  (Table Foreign Keys)
-- 
-- Dependencies: 
--    QRYS_SEL (Table)
ALTER TABLE OPAL_FRA.QRYS_SEL_RS4DIMS ADD (
  CONSTRAINT R_QRYS_SEL_RS4DIMS 
  FOREIGN KEY (QRY_ID, ORDNO) 
  REFERENCES OPAL_FRA.QRYS_SEL (QRY_ID, ORDNO)
  ON DELETE CASCADE
  ENABLE VALIDATE);