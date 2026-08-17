CLASS zcl_work_order_validator_lgo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS validate_create_order
      IMPORTING iv_customer_id   TYPE zde_customer_id_lgo
                iv_technician_id TYPE zde_technician_id_lgo
                iv_priority      TYPE zde_priority_lgo
                iv_status        TYPE zde_status_lgo
      RETURNING VALUE(rv_valid)  TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_customer
      IMPORTING iv_customer_id  TYPE zde_customer_id_lgo
      RETURNING VALUE(rv_valid) TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_technician
      IMPORTING iv_technician_id TYPE zde_technician_id_lgo
      RETURNING VALUE(rv_valid)  TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_priority
      IMPORTING iv_priority     TYPE zde_priority_lgo
      RETURNING VALUE(rv_valid) TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_status
      IMPORTING iv_status       TYPE zde_status_lgo
      RETURNING VALUE(rv_valid) TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_status_and_priority
      IMPORTING iv_status       TYPE zde_status_lgo
                iv_priority     TYPE zde_priority_lgo
      RETURNING VALUE(rv_valid) TYPE abap_bool
      RAISING   zcx_validation_lgo.

    METHODS validate_update_order
        IMPORTING iv_work_order_id TYPE zde_work_order_id_lgo
        RETURNING VALUE(rv_valid)  TYPE abap_bool
        RAISING   zcx_validation_lgo.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_work_order_validator_lgo IMPLEMENTATION.

  METHOD validate_create_order.

    validate_customer( iv_customer_id ).
    validate_technician( iv_technician_id ).
    validate_status_and_priority(
      iv_status   = iv_status
      iv_priority = iv_priority ).

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_customer.
    DATA lt_customer TYPE STANDARD TABLE OF ztcustomer_lgo.
    SELECT * FROM ztcustomer_lgo
      WHERE customer_id = @iv_customer_id
      INTO TABLE @lt_customer.
    IF line_exists( lt_customer[ customer_id = iv_customer_id ] ).
      rv_valid = abap_true.
    ELSE.
      RAISE EXCEPTION TYPE zcx_validation_lgo
        EXPORTING
          textid = zcx_validation_lgo=>customer_not_found.
    ENDIF.
  ENDMETHOD.

  METHOD validate_technician.
    DATA lt_technician TYPE STANDARD TABLE OF zttechnician_lgo.
    SELECT * FROM zttechnician_lgo
      WHERE technician_id = @iv_technician_id
      INTO TABLE @lt_technician.
    IF line_exists( lt_technician[ technician_id = iv_technician_id ] ).
      rv_valid = abap_true.
    ELSE.
      RAISE EXCEPTION TYPE zcx_validation_lgo
        EXPORTING
          textid = zcx_validation_lgo=>technician_not_found.
    ENDIF.
  ENDMETHOD.

  METHOD validate_priority.
    CASE iv_priority.
      WHEN 'A' OR 'B'.
        rv_valid = abap_true.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_validation_lgo
          EXPORTING
            textid = zcx_validation_lgo=>invalid_priority.
    ENDCASE.
  ENDMETHOD.

  METHOD validate_status.
    CASE iv_status.
      WHEN 'PE'.
        rv_valid = abap_true.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_validation_lgo
          EXPORTING
            textid = zcx_validation_lgo=>invalid_status.
    ENDCASE.
  ENDMETHOD.

  METHOD validate_status_and_priority.
    validate_status( iv_status ).
    validate_priority( iv_priority ).
    rv_valid = abap_true.
  ENDMETHOD.

  METHOD validate_update_order.

  DATA lt_work_order TYPE STANDARD TABLE OF ztwork_order_lgo.

  SELECT * FROM ztwork_order_lgo
    WHERE work_order_id = @iv_work_order_id
    INTO TABLE @lt_work_order.

  IF NOT line_exists( lt_work_order[ work_order_id = iv_work_order_id ] ).
    RAISE EXCEPTION TYPE zcx_validation_lgo
      EXPORTING
        textid = zcx_validation_lgo=>work_order_not_found.
  ELSEIF lt_work_order[ work_order_id = iv_work_order_id ]-status <> 'PE'.
    RAISE EXCEPTION TYPE zcx_validation_lgo
      EXPORTING
        textid = zcx_validation_lgo=>invalid_status_for_update.
  ENDIF.

  rv_valid = abap_true.

    ENDMETHOD.

ENDCLASS.
