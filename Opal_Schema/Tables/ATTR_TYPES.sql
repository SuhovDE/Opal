--
-- ATTR_TYPES  (Table) 
--
--  Dependencies: 
--   DOMAINS (Table)
--
--   Row Count: 53
CREATE TABLE OPAL_FRA.ATTR_TYPES
(
  ID              INTEGER,
  DESCR           VARCHAR2(50 CHAR)             NOT NULL,
  CD              VARCHAR2(2 CHAR),
  PARENT_ID       INTEGER,
  TYPE_SIZE       INTEGER,
  TYPE_PRECISION  INTEGER,
  TYPE_KIND       CHAR(1 BYTE)                  DEFAULT 'B',
  DIM_LEV_ID      INTEGER,
  TYPE_MASK       VARCHAR2(30 CHAR),
  DOM_ID          INTEGER                       NOT NULL,
  SCODE           VARCHAR2(30 CHAR),
  DISPLAY_FORMAT  VARCHAR2(30 BYTE)
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

COMMENT ON TABLE OPAL_FRA.ATTR_TYPES IS 'Types of attributes';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.ID IS 'ID of the type for references';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.DESCR IS 'Description';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.CD IS 'C - continuous type, D - discrete';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.PARENT_ID IS 'Parent type ID';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.TYPE_SIZE IS 'Default size of attributes of the current type';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.TYPE_PRECISION IS 'Default precision of attributes of the current type';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.TYPE_KIND IS 'B - basic type, D - dimensional';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.TYPE_MASK IS 'Mask for basic for showing on the screen type';

COMMENT ON COLUMN OPAL_FRA.ATTR_TYPES.DOM_ID IS 'Ref to domains';