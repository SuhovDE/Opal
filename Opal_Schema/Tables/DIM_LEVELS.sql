--
-- DIM_LEVELS  (Table) 
--
--  Dependencies: 
--   DIMS (Table)
--
--   Row Count: 41
CREATE TABLE OPAL_FRA.DIM_LEVELS
(
  DIM_ID           INTEGER                      NOT NULL,
  ORDNO            INTEGER                      NOT NULL,
  ID               INTEGER,
  TAB_NAME         VARCHAR2(30 CHAR)            NOT NULL,
  COL_NAME         VARCHAR2(30 CHAR)            DEFAULT 'CODE'                NOT NULL,
  PARENT_COL_NAME  VARCHAR2(30 CHAR),
  COL_IN_DIMS      VARCHAR2(30 CHAR),
  STORAGE_TYPE     INTEGER                      DEFAULT -4,
  DOM_ID           INTEGER                      NOT NULL,
  SCODE            VARCHAR2(30 CHAR),
  SPLIT_MODE       CHAR(1 BYTE)                 DEFAULT '1',
  SUF              VARCHAR2(40 CHAR),
  ABBR             VARCHAR2(40 CHAR),
  SHORT            VARCHAR2(256 CHAR),
  FULL             VARCHAR2(4000 CHAR)
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

COMMENT ON TABLE OPAL_FRA.DIM_LEVELS IS 'Levels of dimensions of the system';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.DIM_ID IS 'Numbering starts with 100, not to mix witrh DIM_ID numbering';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.ORDNO IS 'Number of dimension level depth';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.TAB_NAME IS 'Table name for values of the current dimension level';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.COL_NAME IS 'Column name for dimension level values';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.PARENT_COL_NAME IS 'Column name for values for parent dimension level of the current dimension level';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.COL_IN_DIMS IS 'Name of a column in dims.tabname, if exists';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.STORAGE_TYPE IS 'Storage type of dimension level';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.DOM_ID IS 'Ref to domains';

COMMENT ON COLUMN OPAL_FRA.DIM_LEVELS.SPLIT_MODE IS 'Mode of splitting of long groups: 1 - to parts of equal length (default), 2 - one-letter alphabetical';