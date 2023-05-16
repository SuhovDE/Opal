--
-- OBJ_COL_NAMES  (Table) 
--
--  Dependencies: 
--   OBJ_COL_IDS (Table)
--   LANGUAGES (Table)
--
--   Row Count: 704
CREATE TABLE OPAL_FRA.OBJ_COL_NAMES
(
  COL_ID   INTEGER,
  ROW_ID   VARCHAR2(30 CHAR),
  LANG_ID  INTEGER                              DEFAULT 1                     NOT NULL,
  SUF      VARCHAR2(40 CHAR),
  ABBR     VARCHAR2(40 CHAR),
  SHORT    VARCHAR2(256 CHAR),
  FULL     VARCHAR2(4000 CHAR)
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