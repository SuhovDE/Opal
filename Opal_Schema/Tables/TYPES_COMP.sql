--
-- TYPES_COMP  (Table) 
--
--  Dependencies: 
--   DIM_LEVELS (Table)
--   FUNC_ROW_ (Table)
--
--   Row Count: 68
CREATE TABLE OPAL_FRA.TYPES_COMP
(
  TYPE_ID       INTEGER,
  COMP_TYPE_ID  INTEGER,
  FUN_ROW_CONV  VARCHAR2(30 CHAR),
  FUN_ROW_BACK  VARCHAR2(30 CHAR),
  IN_DIM        NUMBER(1),
  STORAGE_TYPE  INTEGER
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

COMMENT ON TABLE OPAL_FRA.TYPES_COMP IS 'Compatibility of attribute types';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.TYPE_ID IS 'Ref to attr_types';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.COMP_TYPE_ID IS 'Compatible type';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.FUN_ROW_CONV IS 'Conversion function from type to comp_type';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.FUN_ROW_BACK IS 'Conversion function from comp_type to type';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.IN_DIM IS '1 - id and comp_id in the same dimension, 0 - not';

COMMENT ON COLUMN OPAL_FRA.TYPES_COMP.STORAGE_TYPE IS 'Storage type to ensure the convert function compatibility';