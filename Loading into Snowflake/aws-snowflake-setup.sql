--  Create an IAM Role in AWS 

use role accountadmin;

-- Create an integration object ------
CREATE STORAGE INTEGRATION aws_sf_data
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = ''
  STORAGE_ALLOWED_LOCATIONS = ('{}');

desc INTEGRATION aws_sf_data;

grant usage on integration aws_sf_data to role sysadmin;

grant create stage on schema "ECOMMERCE_DB"."ECOMMERCE_DEV" to role sysadmin;

use role sysadmin;

create schema ecommerce_dev;

use schema "ECOMMERCE_DB"."ECOMMERCE_DEV";

create table lineitem cluster by (L_SHIPDATE) as select * from "ECOMMERCE_DB"."ECOMMERCE_LIV"."LINEITEM" limit 1;
truncate table lineitem;

CREATE FILE FORMAT csv_load_format
    TYPE = 'CSV' 
    COMPRESSION = 'AUTO' 
    FIELD_DELIMITER = ',' 
    RECORD_DELIMITER = '\n' 
    SKIP_HEADER =1 
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
    TRIM_SPACE = FALSE 
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
    ESCAPE = 'NONE' 
    ESCAPE_UNENCLOSED_FIELD = '\134' 
    DATE_FORMAT = 'AUTO' 
    TIMESTAMP_FORMAT = 'AUTO';

create stage stg_lineitem_csv_dev
storage_integration = aws_sf_data
url = ''
file_format = csv_load_format;

list @lineitem_dev_load;

copy into lineitem
from @stg_lineitem_csv_dev 
file_format = csv_loading_format 
ON_ERROR = ABORT_STATEMENT;

select *
from table(
        information_schema.copy_history(
            table_name = > 'lineitem',
            start_time = > dateadd(hours, -1, current_timestamp())
        )
    );

select * from information_schema.load_history where table_name='LINEITEM' order by last_load_time desc limit 10;






