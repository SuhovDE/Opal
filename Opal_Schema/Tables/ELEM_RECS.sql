--
-- ELEM_RECS  (Table) 
--
--   Row Count: 14
CREATE TABLE OPAL_FRA.ELEM_RECS
(
  ID  VARCHAR2(30 CHAR)
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

COMMENT ON TABLE OPAL_FRA.ELEM_RECS IS 'Elementary records (tables and views) for the system';

COMMENT ON COLUMN OPAL_FRA.ELEM_RECS.ID IS 'Table (view) name';