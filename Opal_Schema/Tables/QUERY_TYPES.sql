--
-- QUERY_TYPES  (Table) 
--
--   Row Count: 4
CREATE TABLE OPAL_FRA.QUERY_TYPES
(
  ID               INTEGER,
  GROUPS_ALLOWED   CHAR(1 BYTE),
  HAVING_ALLOWED   CHAR(1 BYTE),
  COMPARE_ALLOWED  CHAR(1 BYTE),
  ORDER_ALLOWED    CHAR(1 BYTE),
  TOP_ALLOWED      CHAR(1 BYTE),
  SUF              VARCHAR2(40 CHAR),
  ABBR             VARCHAR2(40 CHAR),
  SHORT            VARCHAR2(256 CHAR),
  FULL             VARCHAR2(4000 CHAR)
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

COMMENT ON TABLE OPAL_FRA.QUERY_TYPES IS 'Types of queries, their key value are hard-coded';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.ID IS 'PK';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.GROUPS_ALLOWED IS 'Group by condition for this type of the query: M - mandatory, O - optional, N - no grouping';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.HAVING_ALLOWED IS 'Having condition for this type of the query: M - mandatory, O - optional, N - no havinging';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.COMPARE_ALLOWED IS 'Compare-style query for this type of the query: M - mandatory, O - optional, N - no compare';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.ORDER_ALLOWED IS 'Order by condition for this type of the query: M - mandatory, O - optional, N - no order';

COMMENT ON COLUMN OPAL_FRA.QUERY_TYPES.TOP_ALLOWED IS 'Top/bottom condition for this type of the query: M - mandatory, O - optional, N - no top/bottom';