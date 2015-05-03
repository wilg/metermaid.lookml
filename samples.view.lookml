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
    
  - dimension: additional_metadata
    sql: ${TABLE}.additional_metadata
    hidden: true
    
  - dimension: user_name
    sql: ${additional_metadata} ->> 'username'
    
  # ESPI WACKINESS
    
  - dimension: currency
    sql_case:
      USD: ${TABLE}.reading_type_currency = 840
    hidden: true
    
  # Find values at: https://naesb.org//copyright/espi.xsd
  # In hundred-thousandths of the currency
  - dimension: price_per_unit
    description: Price for a single unit of energy at the time of this sample.
    sql: ${TABLE}.cost::double precision / 100000
    type: number
    decimals: 6
    value_format: '$#,##0.000'
    
  - dimension: cost
    description: Final billed cost of this sample.
    sql: ${price_per_unit} * COALESCE(${kwh}, ${therms})
    type: number
    decimals: 6
    value_format: '$#,##0.000'
    
  - dimension: power_of_10
    type: int
    sql: ${TABLE}.reading_type_power_of_ten_multiplier
    hidden: true

  # Find values at: https://naesb.org//copyright/espi.xsd
  - dimension: unit_of_measure
    type: int
    sql: ${TABLE}.reading_type_uom
    hidden: true

  - dimension: time_period_duration
    type: int
    sql: ${TABLE}.time_period_duration
    hidden: true

  - dimension: usage_point_service_category_kind
    type: int
    sql: ${TABLE}.usage_point_service_category_kind
    hidden: true

  - dimension: value
    type: int
    sql: |
      CASE WHEN ${power_of_10} = 0 THEN
        ${TABLE}.value
      ELSE 
        POWER(10, ${power_of_10}) * ${TABLE}.value::double precision
      END
    hidden: true

  # READINGS

  - dimension: type
    sql_case:
      Gas: ${unit_of_measure} = 169
      Electric: ${unit_of_measure} = 72

  - dimension: kwh
    label: kWh
    decimals: 3
    type: number
    sql: |
      CASE WHEN ${unit_of_measure} = 72 THEN
        0.001 * ${value}
      ELSE 
        NULL
      END

  - dimension: therms
    decimals: 3
    type: number
    sql: |
      CASE WHEN ${unit_of_measure} = 169 THEN
        ${value}
      ELSE 
        NULL
      END
      
  - dimension: address
    sql: ${TABLE}.address

  - dimension_group: time
    label: ""
    type: time
    timeframes: [date, week, month, year, hour, hour_of_day, day_of_week, day_of_month]
    datatype: epoch
    sql: ${TABLE}.time_period_start
    
  - measure: data_age
    description: Hours since the last sample.
    type: number
    value_format: 0" hours"
    sql: |
      EXTRACT(epoch FROM
        (current_timestamp - to_timestamp(MAX(${TABLE}.time_period_start)))
      ) / 3600

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
    
  - measure: total_therms
    decimals: 3
    type: sum
    sql: ${therms}
    
  - measure: average_therms
    type: average
    decimals: 3
    sql: ${therms}
    
  - measure: total_price_per_unit
    decimals: 3
    type: sum
    sql: ${price_per_unit}
    value_format: '$#,##0.000'

  - measure: average_price_per_unit
    decimals: 3
    type: average
    sql: ${price_per_unit}
    value_format: '$#,##0.000'

  - measure: total_cost
    decimals: 3
    type: sum
    sql: ${cost}
    value_format: '$#,##0.000'

  - measure: average_cost
    decimals: 3
    type: average
    sql: ${cost}
    value_format: '$#,##0.000'
