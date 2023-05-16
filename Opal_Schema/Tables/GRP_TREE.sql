--
-- GRP_TREE  (Table) 
--
--  Dependencies: 
--   GROUPS (Table)
--
--   Row Count: 57400
CREATE TABLE OPAL_FRA.GRP_TREE
(
  ID             INTEGER,
  PARENT_ID      INTEGER,
  ORDNO_IN_ROOT  INTEGER,
  ALLREST        CHAR(1 BYTE),
  DATE_FROM      DATE,
  DATE_TO        DATE
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

COMMENT ON TABLE OPAL_FRA.GRP_TREE IS 'Nested groups tree';

COMMENT ON COLUMN OPAL_FRA.GRP_TREE.ID IS 'Group Id of the level';

COMMENT ON COLUMN OPAL_FRA.GRP_TREE.PARENT_ID IS 'ID of the parent node';

COMMENT ON COLUMN OPAL_FRA.GRP_TREE.ORDNO_IN_ROOT IS 'Order of the child nodes of the same parent, if needed (for C groups, e.g.)';

COMMENT ON COLUMN OPAL_FRA.GRP_TREE.ALLREST IS 'R - rest by all the nodes of the same level';