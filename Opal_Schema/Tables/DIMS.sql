--
-- DIMS  (Table) 
--
--  Dependencies: 
--   DIMS (Table)
--
--   Row Count: 35
CREATE TABLE OPAL_FRA.DIMS
(
  ID                INTEGER,
  ADD_DIM           VARCHAR2(1 CHAR)            DEFAULT 'Y',
  TABNAME           VARCHAR2(30 CHAR),
  PARENT_ID         INTEGER,
  DOM_ID            INTEGER                     NOT NULL,
  SCODE             VARCHAR2(30 CHAR),
  SHOW_BASIC_LEVEL  NUMBER(1),
  SUF               VARCHAR2(40 CHAR),
  ABBR              VARCHAR2(40 CHAR),
  SHORT             VARCHAR2(256 CHAR),
  FULL              VARCHAR2(4000 CHAR)
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

COMMENT ON TABLE OPAL_FRA.DIMS IS 'Dimensions of the system';

COMMENT ON COLUMN OPAL_FRA.DIMS.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.DIMS.ADD_DIM IS 'Y - add dim_level name to code while expanding the dimension to a group (not needed for real work) ';

COMMENT ON COLUMN OPAL_FRA.DIMS.TABNAME IS 'Name of a common table for dimension, if exists';

COMMENT ON COLUMN OPAL_FRA.DIMS.PARENT_ID IS 'The domain id for dimension';

COMMENT ON COLUMN OPAL_FRA.DIMS.DOM_ID IS 'Ref to domains';

COMMENT ON COLUMN OPAL_FRA.DIMS.SHOW_BASIC_LEVEL IS 'Not null - basic level of the dimension must be shown at columns header';