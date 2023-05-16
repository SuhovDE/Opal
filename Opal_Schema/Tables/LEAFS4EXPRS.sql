--
-- LEAFS4EXPRS  (Table) 
--
--  Dependencies: 
--   EXPRS (Table)
--
--   Row Count: 27
CREATE TABLE OPAL_FRA.LEAFS4EXPRS
(
  LEAF_ID      INTEGER                          NOT NULL,
  IS_LEAF      INTEGER                          DEFAULT 1,
  UN_SIGN      CHAR(1 BYTE),
  CONST        VARCHAR2(4000 CHAR),
  ATTR_ID      INTEGER,
  FUNC_ROW_ID  VARCHAR2(30 CHAR)
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

COMMENT ON TABLE OPAL_FRA.LEAFS4EXPRS IS 'Leaf properties for expressions, each leaf is [-]f(attr)';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.LEAF_ID IS 'Ref to an expression tree';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.IS_LEAF IS '1 always';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.UN_SIGN IS '- or empty';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.CONST IS 'constant in expression';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.ATTR_ID IS 'ref to attr_id, empty if CONSTANT is not empty';

COMMENT ON COLUMN OPAL_FRA.LEAFS4EXPRS.FUNC_ROW_ID IS 'ref to row function, applied to the attribute/constant';