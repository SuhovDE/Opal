--
-- GROUPS  (Table) 
--
--   Row Count: 52496
CREATE TABLE OPAL_FRA.GROUPS
(
  ID           INTEGER,
  PREDEFINED   CHAR(1 BYTE)                     DEFAULT 'P',
  GRP_TYPE     CHAR(1 BYTE),
  IS_LEAF      INTEGER,
  TYPE_ID      INTEGER,
  DIM_ID       INTEGER,
  GRP_SUBTYPE  NUMBER(2),
  DOM_ID       INTEGER,
  IS_GRP_PRIV  CHAR(1 CHAR),
  CR_USER      VARCHAR2(30 CHAR),
  SUF          VARCHAR2(40 CHAR),
  ABBR         VARCHAR2(40 CHAR),
  SHORT        VARCHAR2(256 CHAR),
  FULL         VARCHAR2(4000 CHAR)
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

COMMENT ON TABLE OPAL_FRA.GROUPS IS 'Nested groups tree root nodes';

COMMENT ON COLUMN OPAL_FRA.GROUPS.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.GROUPS.PREDEFINED IS 'Y - predefined group (is supplied with the system), N - no (delete with query, don"t show for grouping), P - persistant (show and don"t delete), D - dimensional (representing a dimension)';

COMMENT ON COLUMN OPAL_FRA.GROUPS.GRP_TYPE IS 'Group of: A -  discrete attributes, C - continious attributes, D - dimension values';

COMMENT ON COLUMN OPAL_FRA.GROUPS.IS_LEAF IS '1 - leaf group, null - not';

COMMENT ON COLUMN OPAL_FRA.GROUPS.TYPE_ID IS 'Not null - group is for any element of the chosen ATTR_TYPE.ID';

COMMENT ON COLUMN OPAL_FRA.GROUPS.DIM_ID IS 'Reference to dimensiod (for groups of typ D)';

COMMENT ON COLUMN OPAL_FRA.GROUPS.GRP_SUBTYPE IS 'For continuous groups: 1 bit: set - interval group of 1st subtype, not set - of the 2nd; 2 bit - set - upper bound with equality, not - no. For placeholders: 0 - group placeholder, 1 - operation placeholder';

COMMENT ON COLUMN OPAL_FRA.GROUPS.DOM_ID IS 'Ref to domains';

COMMENT ON COLUMN OPAL_FRA.GROUPS.IS_GRP_PRIV IS 'Group is accessible to everybody, except of CR_USER: P - Public (no restrictions); N - No corrections';