--
-- OBJ_IDS  (Table) 
--
--   Row Count: 11
CREATE TABLE OPAL_FRA.OBJ_IDS
(
  OBJ_NAME  VARCHAR2(30 CHAR)                   NOT NULL,
  ID        INTEGER,
  OBJ_TYPE  CHAR(1 BYTE)                        DEFAULT 'T'
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