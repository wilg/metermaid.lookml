- view: samples
  sql_table_name: metermaid_samples
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: address
    sql: ${TABLE}.address

  - dimension: filename
    sql: ${TABLE}.filename

  - dimension: reading_type_currency
    type: int
    sql: ${TABLE}.reading_type_currency

  - dimension: reading_type_power_of_ten_multiplier
    type: int
    sql: ${TABLE}.reading_type_power_of_ten_multiplier

  - dimension: reading_type_uom
    type: int
    sql: ${TABLE}.reading_type_uom

  - dimension: sample_hash
    sql: ${TABLE}.sample_hash

  - dimension: time_period_duration
    type: int
    sql: ${TABLE}.time_period_duration

  - dimension: time_period_start
    type: int
    sql: ${TABLE}.time_period_start

  - dimension: usage_point_service_category_kind
    type: int
    sql: ${TABLE}.usage_point_service_category_kind

  - dimension: value
    type: int
    sql: ${TABLE}.value

  - measure: count
    type: count
    drill_fields: [id, filename]

