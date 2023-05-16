--
-- GROUPS_GL  (Table) 
--
--  Dependencies: 
--   GROUPS_GL (Table)
--   GRP_TREE (Table)
--
--   Row Count: 13219
CREATE TABLE OPAL_FRA.GROUPS_GL
(
  ID             INTEGER,
  PID            INTEGER,
  GL_ID          INTEGER,
  GL_PID         INTEGER,
  ORDNO_IN_ROOT  INTEGER,
  LVL            INTEGER,
  FID            INTEGER,
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

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.ID IS 'Group ID from groups';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.PID IS 'Parent group ID from GRP_TREE';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.GL_ID IS 'Global group ID in the tree';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.GL_PID IS 'Global ID of the parent group in the tree';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.ORDNO_IN_ROOT IS 'Similar to GRP_TREE column';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.LVL IS 'Similar to GRP_TREE column';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.FID IS 'Group ID of the first not-trivial ansector node';

COMMENT ON COLUMN OPAL_FRA.GROUPS_GL.ALLREST IS 'Similar to GRP_TREE column';