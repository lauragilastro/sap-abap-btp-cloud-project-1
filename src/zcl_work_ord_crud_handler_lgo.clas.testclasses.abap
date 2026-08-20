CLASS ltcl_CRUD_test DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_work_ord_crud_handler_lgo.
    METHODS:
    setup, " Create zcl_work_ord_crud_handler_lgo object in each METHOD

    " Happy end
    create_work_order_test_ok FOR TESTING,
    update_work_order_test_ok FOR TESTING,
    delete_work_order_test_ok FOR TESTING,
    read_work_order_test_ok FOR TESTING,
    read_history_test_ok FOR TESTING,

    " Error end
    create_work_order_test_error FOR TESTING,
    update1_work_order_test_error FOR TESTING,
    update2_work_order_test_error FOR TESTING,
    delete_work_order_test_error FOR TESTING,
    read_work_order_test_error FOR TESTING,
    read_history_test_error FOR TESTING.

ENDCLASS.

CLASS ltcl_CRUD_test IMPLEMENTATION.

    METHOD setup.
        CREATE OBJECT cut.
        " Before validating create customer and technician
        INSERT ztcustomer_lgo FROM @( VALUE #(
          client      = sy-mandt
          customer_id = '12345678'
          name        = 'Laura'
          address     = 'Calle Falsa 123'
          phone       = '600000000' ) ).

        INSERT zttechnician_lgo FROM @( VALUE #(
          client        = sy-mandt
          technician_id = '87654321'
          name          = 'Norberto'
          specialty     = 'Electricidad' ) ).
    ENDMETHOD.

    " HAPPY END SECTION
    METHOD create_work_order_test_ok.

    " Needed data to create the work order
    DATA(lv_resultado) = cut->create_work_order(
    iv_customer_id   = '12345678'
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    cl_abap_unit_assert=>assert_char_cp(
        act = lv_resultado
        exp = '*created*'
        msg = 'Work order not created' ).

    ENDMETHOD.

    METHOD update_work_order_test_ok.

    " First create work order data
    DATA(lv_create_wo) = cut->create_work_order(
    iv_customer_id   = '12345678'
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    " Data already exists in WO table, so we put data inside variable selected by ID
    SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

    " We know which row is thanks of work order ID
    DATA(lv_resultado) = cut->update_work_order( iv_work_order_id = lv_wo_created ).

    " We brought data among variables to finally arrives to result

    cl_abap_unit_assert=>assert_char_cp(
    act = lv_resultado
    exp = '*updated*'
    msg = 'Work order not updated' ).

    ENDMETHOD.

    METHOD delete_work_order_test_ok.

    " First create work order data
    DATA(lv_create_wo) = cut->create_work_order(
    iv_customer_id   = '12345678'
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    " Data already exists in WO table, so we put data inside variable selected by ID
    SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

    " Program tries to delete it can bc exists and it's PE
    DATA(lv_resultado) = cut->delete_work_order( iv_work_order_id = lv_wo_created ).

    cl_abap_unit_assert=>assert_char_cp(
    act = lv_resultado
    exp = '*deleted*'
    msg = 'Work order not deleted' ).


    ENDMETHOD.

    METHOD read_work_order_test_ok.

    DATA(lv_create_wo) = cut->create_work_order(
    iv_customer_id   = '12345678'
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

    DATA(lv_result_wo_readed) = cut->read_work_order( iv_work_order_id = lv_wo_created ).

    cl_abap_unit_assert=>assert_equals(
    act = lv_result_wo_readed-customer_id
    exp = '12345678'
    msg = 'customer_id doesnt coincide' ).

    ENDMETHOD.

    METHOD read_history_test_ok.

    DATA(lv_create_wo) = cut->create_work_order(
    iv_customer_id   = '12345678'
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

    cut->update_work_order( iv_work_order_id = lv_wo_created ). " Because history doesn's exist without update method

    DATA(lt_result_hist) = cut->read_history( iv_work_order_id = lv_wo_created ).

    cl_abap_unit_assert=>assert_not_initial(
    act = lt_result_hist
    msg = 'History not found' ).

    ENDMETHOD.

    " ERROR END SECTION
    METHOD create_work_order_test_error.

    DATA(lv_resultado) = cut->create_work_order(
    iv_customer_id   = '00000000' " Wrong on purpose
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random' ).

  cl_abap_unit_assert=>assert_not_initial(
    act = lv_resultado
    msg = 'Customer not found' ).

    ENDMETHOD.

    METHOD update1_work_order_test_error. " Op1 Doesnt exist, cannot be updated

    DATA(lv_resultado) = cut->update_work_order( iv_work_order_id = '00000000' ). " Tries to update a never-created data

    cl_abap_unit_assert=>assert_not_initial(
    act = lv_resultado
    msg = 'Work order doesnt exist' ).

    ENDMETHOD.

    METHOD update2_work_order_test_error. " Op2 Exists but is already CO bc was updated

    cut->create_work_order(
    iv_customer_id   = '12345678' " Data is correct
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random' ).

  SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

  cut->update_work_order( iv_work_order_id = lv_wo_created ).  " Transforms PE to CO

  " Is not PE its already CO so cant be updated
  DATA(lv_resultado) = cut->update_work_order( iv_work_order_id = lv_wo_created ).

    cl_abap_unit_assert=>assert_not_initial(
    act = lv_resultado
    msg = 'Work order already processed' ).

    ENDMETHOD.

    METHOD delete_work_order_test_error.

    " First create work order data
    DATA(lv_create_wo) = cut->create_work_order(
    iv_customer_id   = '12345678' " Data is correct
    iv_technician_id = '87654321'
    iv_priority      = 'A'
    iv_description   = 'Frase random'
    ).

    SELECT SINGLE FROM ztwork_order_lgo
    FIELDS MAX( work_order_id )
    INTO @DATA(lv_wo_created).

    " Work order processed so technician updates
    cut->update_work_order( iv_work_order_id = lv_wo_created ).

    " Work order cannot be deleted because is CO --> already processed
    DATA(lv_resultado) = cut->delete_work_order( iv_work_order_id = lv_wo_created ).

    cl_abap_unit_assert=>assert_not_initial(
    act = lv_resultado
    msg = 'Work order already processed' ).

    ENDMETHOD.

    METHOD read_work_order_test_error.

    DATA(lv_resultado) = cut->read_work_order( iv_work_order_id = '00000000' ). " Tries to update a never-created data

    cl_abap_unit_assert=>assert_initial( " Initial because not even text-error-message to show
    act = lv_resultado
    msg = 'Work order doesnt exist' ).

    ENDMETHOD.

    METHOD read_history_test_error.

    DATA(lv_resultado) = cut->read_history( iv_work_order_id = '00000000' ). " Tries to update a never-created data

    cl_abap_unit_assert=>assert_initial(
    act = lv_resultado
    msg = 'Work order doesnt exist' ).

    ENDMETHOD.

ENDCLASS.
