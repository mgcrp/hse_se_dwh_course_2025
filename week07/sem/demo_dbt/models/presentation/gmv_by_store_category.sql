{{
    config(
        materialized = 'table',
        schema = 'presenation'
    )
}}

with pre as (
    SELECT
       pu.store_id, pr.category_id,
       sum(pi.product_price * pi.product_count) as sales_sum
    from {{ source('postgres_business', 'purchase_items') }} pi
    join {{ source('postgres_business', 'products') }} pr
        on pi.product_id = pr.product_id
    join {{ source('postgres_business', 'purchases') }} pu
        on pu.purchase_id = pi.purchase_id
    group by pu.store_id, pr.category_id
)
select *
from pre