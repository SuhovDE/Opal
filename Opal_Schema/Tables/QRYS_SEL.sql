--
-- QRYS_SEL  (Table) 
--
--  Dependencies: 
--   ATTRS2CUBES (Table)
--   QRYS (Table)
--
--   Row Count: 19968
CREATE TABLE OPAL_FRA.QRYS_SEL
(
  QRY_ID         INTEGER,
  ATTR_ID        INTEGER                        NOT NULL,
  FUNC_GRP_ID    VARCHAR2(30 CHAR),
  GRP_ID         INTEGER,
  GRP_LEV_ORDNO  INTEGER,
  ORDNO          INTEGER,
  QRY_SEL_ID     INTEGER                        NOT NULL,
  CUBE_ID        INTEGER                        NOT NULL,
  DIM_LEV_ID     INTEGER                        DEFAULT null,
  NOSHOW         INTEGER                        DEFAULT null,
  HOW            NUMBER(3)                      DEFAULT '0'                   NOT NULL
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

COMMENT ON TABLE OPAL_FRA.QRYS_SEL IS 'Query''s select list description, in tree grouping (query of the 4th type) additionally  data, describing grouping levels can be added';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.QRY_ID IS 'Ref to query';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.ATTR_ID IS 'Ref to attribute';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.FUNC_GRP_ID IS 'ref to group function';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.GRP_ID IS 'Only for group name columns: ref to group';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.GRP_LEV_ORDNO IS 'Only for group name columns: ref to group level';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.ORDNO IS 'Order No in select list';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.QRY_SEL_ID IS 'Original order of attribute in the query';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.CUBE_ID IS 'Added to restrict all the items for the select list by the only cube';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.DIM_LEV_ID IS 'Dim Level of attr_id; 0 - key attr without real dim level';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.NOSHOW IS 'Not null - don"t show the item in select list';

COMMENT ON COLUMN OPAL_FRA.QRYS_SEL.HOW IS 'Flags 1 - Full details, 8 - Rest, 16 - Levels';