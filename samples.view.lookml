- view: samples
  sql_table_name: metermaid_samples
  fields:
  
  # ETL AND JUNK

  # Arbitrary
  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id
    hidden: true

  # Used only to ensure uniqueness in the ETL
  - dimension: sample_hash
    sql: ${TABLE}.sample_hash
    hidden: true
    
  # Irrelevant, usually
  - dimension: filename
    sql: ${TABLE}.filename
    hidden: true
    
  # ESPI WACKINESS
    
  - dimension: reading_type_currency
    type: int
    sql: ${TABLE}.reading_type_currency

  - dimension: reading_type_power_of_ten_multiplier
    type: int
    sql: ${TABLE}.reading_type_power_of_ten_multiplier

  - dimension: reading_type_uom
    type: int
    sql: ${TABLE}.reading_type_uom

  - dimension: time_period_duration
    type: int
    sql: ${TABLE}.time_period_duration

  - dimension: usage_point_service_category_kind
    type: int
    sql: ${TABLE}.usage_point_service_category_kind

  - dimension: value
    type: int
    sql: ${TABLE}.value
    hidden: true

  # READINGS

  - dimension: type
    sql_case:
      Gas: ${reading_type_uom} = 169
      Electric: ${reading_type_uom} = 72

  - dimension: kwh
    label: kWh
    decimals: 3
    type: number
    sql: |
      CASE WHEN ${reading_type_uom} = 72 THEN
        0.001 * CASE WHEN ${reading_type_power_of_ten_multiplier} = 0 THEN
          ${value}
        ELSE 
          ${reading_type_power_of_ten_multiplier} * ${value}::double precision
        END
      ELSE NULL
      END
      
  - dimension: address
    sql: ${TABLE}.address

  - dimension_group: time
    label: ""
    type: time
    timeframes: [date, hour, hour_of_day, day_of_week, day_of_month]
    datatype: epoch
    sql: ${TABLE}.time_period_start

  - measure: count
    type: count
    drill_fields: [id, filename]
    
  - measure: total_kwh
    label: Total kWh
    decimals: 3
    type: sum
    sql: ${kwh}
    
  - measure: average_kwh
    label: Average kWh
    type: average
    decimals: 3
    sql: ${kwh}
