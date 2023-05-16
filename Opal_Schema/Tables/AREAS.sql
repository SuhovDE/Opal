--
-- AREAS  (Table) 
--
--  Dependencies: 
--   AREAS (Table)
--
--   Row Count: 7
CREATE TABLE OPAL_FRA.AREAS
(
  ID         INTEGER,
  PARENT_ID  INTEGER,
  SCODE      VARCHAR2(30 CHAR),
  SUF        VARCHAR2(40 CHAR),
  ABBR       VARCHAR2(40 CHAR),
  SHORT      VARCHAR2(256 CHAR),
  FULL       VARCHAR2(4000 CHAR)
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

COMMENT ON TABLE OPAL_FRA.AREAS IS 'Areas for attributes, used only for logical grouping while data input/display';

COMMENT ON COLUMN OPAL_FRA.AREAS.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.AREAS.PARENT_ID IS 'ID of previous group in hierarchy';