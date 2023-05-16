ALTER TABLE OPAL_FRA.OBJ_IDS ADD (
  CONSTRAINT C_OBJ_IDS_T
  CHECK (obj_type in ('T','M'))
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OBJ_IDS ADD (
  CONSTRAINT PK_OBJ_IDS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.OBJ_IDS ADD (
  CONSTRAINT U_OBJ_IDS_N
  UNIQUE (OBJ_NAME)
  ENABLE VALIDATE);