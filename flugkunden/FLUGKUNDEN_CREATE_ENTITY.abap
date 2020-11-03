DATA: ls_flugkunde_odata TYPE zcl_zflight_01_mpc=>ts_flugkunde,
      ls_flugkunde_bapi TYPE bapiscunew,
      lv_customerid TYPE bapiscudat-customerid,
      lv_nav_path TYPE /iwbep/t_mgw_navigation_path,
      lt_key_tab TYPE /iwbep/t_mgw_name_value_pair,
      ls_key_tab LIKE LINE OF lt_key_tab,
      lt_return TYPE TABLE OF BAPIRET2,
      ls_return TYPE BAPIRET2.
      
CALL METHOD io_data_provider->read_entry_data
  IMPORTING
    es_data = ls_flugkunde_odata.

ls_flugkunde_bapi-city = ls_flugkunde_odata-city.
ls_flugkunde_bapi-countr = ls_flugkunde_odata-countr.
ls_flugkunde_bapi-countr_iso = ls_flugkunde_odata-countr_iso.
ls_flugkunde_bapi-custname = ls_flugkunde_odata-custname.
ls_flugkunde_bapi-custtype = 'B'.
ls_flugkunde_bapi-email = ls_flugkunde_odata-email.
ls_flugkunde_bapi-form = ls_flugkunde_odata-form.
ls_flugkunde_bapi-phone = ls_flugkunde_odata-phone.
ls_flugkunde_bapi-pobox = ls_flugkunde_odata-pobox.
ls_flugkunde_bapi-postcode = ls_flugkunde_odata-postcode.
ls_flugkunde_bapi-region = ls_flugkunde_odata-region.
ls_flugkunde_bapi-street = ls_flugkunde_odata-street.

CALL FUNCTION 'BAPI_FLCUST_CREATEFROMDATA'
  EXPORTING         customer_data  = ls_flugkunde_bapi
*   TEST_RUN       = ' '
  IMPORTING         customernumber = lv_customerid
  TABLES 
*   EXTENSION_IN   =
   return         = lt_return.
   
ls_key_tab-name = 'Customerid'.
ls_key_tab-value = lv_customerid.
APPEND ls_key_tab TO lt_key_tab.

ls_flugkunde_odata-customerid = lv_customerid.

er_entity = ls_flugkunde_odata.

*    me->flugkundeset_get_entity(
*      EXPORTING
*        it_key_tab = lt_key_tab
*        it_navigation_path = lv_nav_path
*        iv_entity_name = iv_entity_name
*        iv_entity_set_name = iv_entity_set_name
*        iv_source_name = iv_source_name
*      IMPORTING
*        er_entity = er_entity
*    ).

IF ls_return IS NOT INITIAL.
   "Ist ls_return gesetzt, werden alle wiedergegebenen Fehler
   "an den Message-Container gegeben und eine Ausnahme
   "geworfen, die all diese Meldungen enthält und die letzte
   "Fehlermeldung als übergeordneten Text anzeigt.
   mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
   RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
    EXPORTING
     message_container = mo_context->get_message_container( )
     message = ls_return-message.
ENDIF.
