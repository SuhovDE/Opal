--
-- QRYS2FOLDERS  (Table) 
--
--   Row Count: 2047
CREATE TABLE OPAL_FRA.QRYS2FOLDERS
(
  QRY_ID     INTEGER,
  FOLDER_ID  INTEGER                            NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );