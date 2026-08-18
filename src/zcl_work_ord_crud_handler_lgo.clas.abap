CLASS zcl_work_ord_crud_handler_lgo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

  METHODS create_work_order
  IMPORTING iv_customer_id   TYPE zde_customer_id_lgo
            iv_technician_id TYPE zde_technician_id_lgo
            iv_priority      TYPE zde_priority_lgo
            iv_description   TYPE ztwork_order_lgo-description
  RETURNING VALUE(rv_result) TYPE string.

  METHODS update_work_order
  IMPORTING iv_work_order_id TYPE zde_work_order_id_lgo
  RETURNING VALUE(rv_result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_work_ord_crud_handler_lgo IMPLEMENTATION.

METHOD create_work_order.

  DATA(lo_validator) = NEW zcl_work_order_validator_lgo( ).

  TRY.
      DATA(lv_valid) = lo_validator->validate_create_order(
                          iv_customer_id   = iv_customer_id
                          iv_technician_id = iv_technician_id
                          iv_priority      = iv_priority
                          iv_status        = 'PE' ).
    CATCH zcx_validation_lgo INTO DATA(lx_error).
      rv_result = lx_error->get_text( ).
      RETURN.
  ENDTRY.

  IF lv_valid = abap_true.

    SELECT SINGLE FROM ztwork_order_lgo
      FIELDS MAX( work_order_id )
      INTO @DATA(lv_max_id).

    INSERT ztwork_order_lgo FROM @( VALUE #(
      client        = sy-mandt
      work_order_id = lv_max_id + 1
      customer_id   = iv_customer_id
      technician_id = iv_technician_id
      creation_date = cl_abap_context_info=>get_system_date( )
      status        = 'PE'
      priority      = iv_priority
      description   = iv_description ) ).

    IF sy-subrc = 0.
      rv_result = |Work order { lv_max_id + 1 } created|.
    ELSE.
      rv_result = 'Error creating work order'.
    ENDIF.

  ENDIF.

ENDMETHOD.

METHOD update_work_order.

  DATA(lo_validator) = NEW zcl_work_order_validator_lgo( ).

  TRY.
      DATA(lv_valid) = lo_validator->validate_update_order( iv_work_order_id = iv_work_order_id ).
    CATCH zcx_validation_lgo INTO DATA(lx_error).
      rv_result = lx_error->get_text( ).
      RETURN.
  ENDTRY.

  IF lv_valid = abap_true.

    UPDATE ztwork_order_lgo SET status = 'CO'
      WHERE work_order_id = @iv_work_order_id.

    IF sy-subrc = 0.

      SELECT SINGLE FROM ztwork_hist_lgo
        FIELDS MAX( history_id )
        INTO @DATA(lv_max_hist_id).

      INSERT ztwork_hist_lgo FROM @( VALUE #(
        client              = sy-mandt
        history_id          = lv_max_hist_id + 1
        work_order_id       = iv_work_order_id
        modification_date   = cl_abap_context_info=>get_system_date( )
        change_description  = 'Status changed from PE to CO' ) ).

      rv_result = |Work order { iv_work_order_id } updated to CO|.

    ELSE.
      rv_result = 'Error updating work order'.
    ENDIF.

  ENDIF.

ENDMETHOD.

ENDCLASS.
