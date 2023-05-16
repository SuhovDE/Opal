--
-- GRP_D  (Table) 
--
--  Dependencies: 
--   CONDS (Table)
--   GROUPS (Table)
--
--   Row Count: 51653
CREATE TABLE OPAL_FRA.GRP_D
(
  GRP_ID        INTEGER                         NOT NULL,
  IS_LEAF       INTEGER                         DEFAULT 1,
  GRP_TYPE      CHAR(1 BYTE)                    DEFAULT 'D',
  DIM_LEV_ID    INTEGER                         NOT NULL,
  DIM_LEV_CODE  VARCHAR2(30 CHAR),
  COND_ID       INTEGER
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

COMMENT ON TABLE OPAL_FRA.GRP_D IS 'Leaf and nodes properties of a Dimensional group (type D)';

COMMENT ON COLUMN OPAL_FRA.GRP_D.GRP_ID IS 'Reference to GRP_TREE';

COMMENT ON COLUMN OPAL_FRA.GRP_D.IS_LEAF IS '1 always';

COMMENT ON COLUMN OPAL_FRA.GRP_D.GRP_TYPE IS 'D always';

COMMENT ON COLUMN OPAL_FRA.GRP_D.DIM_LEV_ID IS 'Reference to dimension level, representing the dimensional group';

COMMENT ON COLUMN OPAL_FRA.GRP_D.DIM_LEV_CODE IS 'Reference to dimension level code, representing the dimensional group (all child codes must be this code children)';

COMMENT ON COLUMN OPAL_FRA.GRP_D.COND_ID IS 'Reference to condition leaf of a dimensional interval group';