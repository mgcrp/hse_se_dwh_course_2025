select *
from {{ ref('gmv_by_store_category') }}
where sales_sum < 0