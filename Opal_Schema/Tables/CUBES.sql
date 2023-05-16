--
-- CUBES  (Table) 
--
--   Row Count: 12
CREATE TABLE OPAL_FRA.CUBES
(
  ID         INTEGER,
  PARENT_ID  INTEGER,
  TAB        VARCHAR2(30 CHAR)                  NOT NULL,
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

COMMENT ON TABLE OPAL_FRA.CUBES IS 'Data cubes of the system';

COMMENT ON COLUMN OPAL_FRA.CUBES.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.CUBES.PARENT_ID IS 'ID of the parent cube';

COMMENT ON COLUMN OPAL_FRA.CUBES.TAB IS 'Table/view name for cube selection';