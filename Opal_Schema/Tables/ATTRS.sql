--
-- ATTRS  (Table) 
--
--  Dependencies: 
--   CATEGORIES (Table)
--   DIM_LEVELS (Table)
--   EXPRS (Table)
--   ATTRS (Table)
--   ATTR_TYPES (Table)
--
--   Row Count: 748
CREATE TABLE OPAL_FRA.ATTRS
(
  ID              INTEGER,
  ATTR_TYPE       INTEGER                       NOT NULL,
  DIM_LEV_ID      INTEGER,
  AREA_ID         INTEGER                       NOT NULL,
  EXPR_ID         INTEGER,
  STORAGE_TYPE    INTEGER,
  ATTR_SIZE       INTEGER                       DEFAULT 10,
  ATTR_PRECISION  INTEGER                       DEFAULT 0,
  PARENT_ID       INTEGER,
  UNIT            VARCHAR2(10 CHAR),
  SCODE           VARCHAR2(30 CHAR),
  HIGHLIGHT       VARCHAR2(1000 CHAR),
  CATEGORY_ID     INTEGER,
  SUF             VARCHAR2(40 CHAR),
  ABBR            VARCHAR2(40 CHAR),
  SHORT           VARCHAR2(256 CHAR),
  FULL            VARCHAR2(4000 CHAR),
  DISPLAY_FORMAT  VARCHAR2(30 BYTE),
  GRP_FUNS        VARCHAR2(30 BYTE)
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

COMMENT ON TABLE OPAL_FRA.ATTRS IS 'Attributes of the system';

COMMENT ON COLUMN OPAL_FRA.ATTRS.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.ATTRS.ATTR_TYPE IS 'Type of the attribute, type Enumerated requires not null DIM_LEV_ID';

COMMENT ON COLUMN OPAL_FRA.ATTRS.DIM_LEV_ID IS 'Required only for ATTR_TYPE Enumerated, refers dimension level, a value of which are allowed for the attribute';

COMMENT ON COLUMN OPAL_FRA.ATTRS.AREA_ID IS 'Reference to attribute''s area';

COMMENT ON COLUMN OPAL_FRA.ATTRS.EXPR_ID IS 'Only for calculated attributes: ref to calculating expression';

COMMENT ON COLUMN OPAL_FRA.ATTRS.STORAGE_TYPE IS 'Storage type of dimensional attributes, is redundant, but provided for convenience ';

COMMENT ON COLUMN OPAL_FRA.ATTRS.ATTR_SIZE IS 'Size of the attribute on the screen';

COMMENT ON COLUMN OPAL_FRA.ATTRS.ATTR_PRECISION IS 'Precision of the numerical data';

COMMENT ON COLUMN OPAL_FRA.ATTRS.UNIT IS 'Unit of measure';

COMMENT ON COLUMN OPAL_FRA.ATTRS.HIGHLIGHT IS 'To store info about the attributes image on the screen (for all cubes)';