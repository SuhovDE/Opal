ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT C_ATTRS_SIZE
  CHECK (nvl(attr_size,0)>0)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT C_ATTRS_STORAGE
  CHECK (nvl(storage_type,0)<>0 )
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT C_ATTRS_TD
  CHECK (dim_lev_id is not null and attr_type>=100  or dim_lev_id is null and attr_type<100)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT P_ATTRS
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT U_ATTRS_N
  UNIQUE (ABBR, PARENT_ID)
  ENABLE VALIDATE);

ALTER TABLE OPAL_FRA.ATTRS ADD (
  CONSTRAINT U_ATTRS_S
  UNIQUE (SCODE)
  ENABLE VALIDATE);