--
-- GRP_TAB_FLAT  (Table) 
--
--   Row Count: 0
CREATE TABLE OPAL_FRA.GRP_TAB_FLAT
(
  CODE        VARCHAR2(10 CHAR),
  GRP_ID      INTEGER,
  DIM_LEV_ID  INTEGER,
  VAL         VARCHAR2(30 CHAR), 
  CONSTRAINT P_GRP_TAB_FLAT
  PRIMARY KEY
  (GRP_ID, CODE, VAL)
  ENABLE VALIDATE
)
ORGANIZATION INDEX
PCTTHRESHOLD 50
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

COMMENT ON TABLE OPAL_FRA.GRP_TAB_FLAT IS 'Table for flattening of dimensional groups. Is supposed to contain all the elements of the base level of all the elements of the top level. Reserved for future optimization';

COMMENT ON COLUMN OPAL_FRA.GRP_TAB_FLAT.CODE IS 'ID from groups';

COMMENT ON COLUMN OPAL_FRA.GRP_TAB_FLAT.GRP_ID IS 'DIM_LEV_CODE from GRP_D of the base level';

COMMENT ON COLUMN OPAL_FRA.GRP_TAB_FLAT.DIM_LEV_ID IS 'Code of the elements of the top level';

COMMENT ON COLUMN OPAL_FRA.GRP_TAB_FLAT.VAL IS 'GROUPS.DIM_LEV_ID of the element';