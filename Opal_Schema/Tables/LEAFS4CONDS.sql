--
-- LEAFS4CONDS  (Table) 
--
--  Dependencies: 
--   FUNC_GRP (Table)
--   OPS (Table)
--
--   Row Count: 13225
CREATE TABLE OPAL_FRA.LEAFS4CONDS
(
  LEAF_ID            INTEGER,
  IS_LEAF            INTEGER                    DEFAULT 1,
  LEFT_ATTR_ID       INTEGER,
  OP_SIGN            VARCHAR2(30 CHAR)          NOT NULL,
  RIGHT_ATTR_ID      INTEGER,
  CONST              VARCHAR2(4000 CHAR),
  GRP_ID             INTEGER,
  LEFT_FUNC_GRP_ID   VARCHAR2(30 CHAR),
  RIGHT_FUNC_GRP_ID  VARCHAR2(30 CHAR),
  IS_COMPARE         CHAR(1 BYTE),
  LEFT_FUNC_ROW_ID   VARCHAR2(30 CHAR),
  RIGHT_FUNC_ROW_ID  VARCHAR2(30 CHAR),
  OP_KIND            VARCHAR2(3 CHAR)           DEFAULT ('L')
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

COMMENT ON TABLE OPAL_FRA.LEAFS4CONDS IS 'Properties of conditions leafs, each leaf condition is a comparison A ? B';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.LEAF_ID IS 'Ref to CONDS';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.IS_LEAF IS '1 always';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.LEFT_ATTR_ID IS 'Ref to the left attribute of comparison';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.OP_SIGN IS 'Comparison operation';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.RIGHT_ATTR_ID IS 'Ref to the right attribute of the comparison';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.CONST IS 'Not NULL, If right attribute is a constant';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.GRP_ID IS 'Not NULL, if OP_SIGN=IN/NOT IN';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.LEFT_FUNC_GRP_ID IS 'group function on the left attribute, only for conditions of the type H';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.RIGHT_FUNC_GRP_ID IS 'group function on the right attribute, only for conditions of the type H';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.IS_COMPARE IS 'C - part of compare-style condition, only for displaying';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.LEFT_FUNC_ROW_ID IS 'Optional row function, applied to the left attribute';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.RIGHT_FUNC_ROW_ID IS 'Optional row function, applied to the right attribute';

COMMENT ON COLUMN OPAL_FRA.LEAFS4CONDS.OP_KIND IS 'Always L, only for references on OPS';