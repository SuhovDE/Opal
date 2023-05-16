--
-- OBJ_COL_IDS  (Table) 
--
--  Dependencies: 
--   OBJ_IDS (Table)
--
--   Row Count: 12
CREATE TABLE OPAL_FRA.OBJ_COL_IDS
(
  OBJ_ID    INTEGER,
  COL_NO    INTEGER,
  COL_ID    INTEGER,
  COL_NAME  VARCHAR2(30 CHAR)                   DEFAULT 'NAME'                NOT NULL
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