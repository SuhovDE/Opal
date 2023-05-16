--
-- ERROR_CODES  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.Error_codes IS
   KEY_NOT_FOUND_N          constant number := -20701;
   KEY_NOT_FOUND            exception;
   PRAGMA EXCEPTION_INIT(KEY_NOT_FOUND, -20701);

   FIELD_FORMAT_IS_WRONG_N  constant number := -20702;
   FIELD_FORMAT_IS_WRONG    exception;
   PRAGMA EXCEPTION_INIT(FIELD_FORMAT_IS_WRONG, -20702);

   KEY_EXISTS_N             constant number := -20703;
   KEY_EXISTS               exception;
   PRAGMA EXCEPTION_INIT(KEY_EXISTS, -20703);

   TABLE_NOT_FOUND_N          constant number := -20704;
   TABLE_NOT_FOUND            exception;
   PRAGMA EXCEPTION_INIT(TABLE_NOT_FOUND, -20704);

   MORE_THAN_1_KEY_N          constant number := -20705;
   MORE_THAN_1_KEY            exception;
   PRAGMA EXCEPTION_INIT(MORE_THAN_1_KEY, -20705);

   PARAMETER_IS_NOT_INITIALIZED_N  constant number := -20707;
   PARAMETER_IS_NOT_INITIALIZED    exception;
   PRAGMA EXCEPTION_INIT(PARAMETER_IS_NOT_INITIALIZED, -20707);

   PARAMETER_MUST_BE_NULL_N  constant number := -20708;
   PARAMETER_MUST_BE_NULL    exception;
   PRAGMA EXCEPTION_INIT(PARAMETER_MUST_BE_NULL, -20708);

   ALGORITHM_ERROR_N  constant number := -20709;
   ALGORITHM_ERROR    exception;
   PRAGMA EXCEPTION_INIT(ALGORITHM_ERROR, -20709);

   CLASSIFICATION_ERROR_N  constant number := -20710;
   CLASSIFICATION_ERROR    exception;
   PRAGMA EXCEPTION_INIT(CLASSIFICATION_ERROR, -20710);
END Error_codes;
 
 
/