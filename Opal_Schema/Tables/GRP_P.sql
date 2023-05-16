--
-- GRP_P  (Table) 
--
--   Row Count: 40
CREATE TABLE OPAL_FRA.GRP_P
(
  GRP_ID    INTEGER                             NOT NULL,
  IS_LEAF   INTEGER                             DEFAULT 1,
  GRP_TYPE  CHAR(1 BYTE)                        DEFAULT 'P',
  FUNC_ID   VARCHAR2(30 CHAR)                   NOT NULL,
  PARAM     VARCHAR2(256 CHAR)
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

COMMENT ON TABLE OPAL_FRA.GRP_P IS 'Leaf and nodes properties of a Placeholder group (type P)';

COMMENT ON COLUMN OPAL_FRA.GRP_P.GRP_ID IS 'Reference to GRP_TREE';

COMMENT ON COLUMN OPAL_FRA.GRP_P.IS_LEAF IS '1 always';

COMMENT ON COLUMN OPAL_FRA.GRP_P.GRP_TYPE IS 'P always';

COMMENT ON COLUMN OPAL_FRA.GRP_P.FUNC_ID IS 'Reference to FUNC_ROW';

COMMENT ON COLUMN OPAL_FRA.GRP_P.PARAM IS 'Parameter to FUNC_ID';