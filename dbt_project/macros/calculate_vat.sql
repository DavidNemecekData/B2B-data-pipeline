{% macro calculate_vat(column_name, vat_rate) %}

    ROUND( {{ column_name }} * (1 + {{ vat_rate }}), 2 )

{% endmacro %}