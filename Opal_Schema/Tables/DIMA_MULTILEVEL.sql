--
-- DIMA_MULTILEVEL  (Table) 
--
--   Row Count: 154579
CREATE TABLE OPAL_FRA.DIMA_MULTILEVEL
(
  F1_C   DATE,
  F2_C   DATE,
  F3_C   VARCHAR2(4 CHAR)                       NOT NULL,
  F3_N   VARCHAR2(60 CHAR),
  F4_C   VARCHAR2(8 CHAR),
  F5     NUMBER,
  F6     NUMBER,
  F7     NUMBER,
  F8_C   INTEGER                                NOT NULL,
  F9_C   VARCHAR2(4 CHAR)                       NOT NULL,
  F9_N   VARCHAR2(50 CHAR),
  F10_C  VARCHAR2(4 CHAR),
  F10_N  VARCHAR2(60 CHAR),
  F11_C  VARCHAR2(10 CHAR),
  F12_N  VARCHAR2(50 CHAR)
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