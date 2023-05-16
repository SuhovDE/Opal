--
-- UNLOADED_IDS  (Table) 
--
--   Row Count: 0
CREATE TABLE OPAL_FRA.UNLOADED_IDS
(
  TABLE_NAME    VARCHAR2(30 CHAR)               NOT NULL,
  COL_NAME      VARCHAR2(30 CHAR)               NOT NULL,
  ID            INTEGER                         NOT NULL,
  UNLOAD_KEY    VARCHAR2(61 CHAR) GENERATED ALWAYS AS (CASE  WHEN "COL_NAME_REF" IS NULL THEN "TABLE_NAME"||'/'||"COL_NAME" END),
  ID_REF        INTEGER,
  COL_NAME_REF  VARCHAR2(30 CHAR)
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

COMMENT ON TABLE OPAL_FRA.UNLOADED_IDS IS 'Used only for exports of period';