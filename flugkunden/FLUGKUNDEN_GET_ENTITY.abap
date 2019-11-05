  METHOD flugkundeset_get_entity.
    DATA: ls_flugkunde     TYPE zcl_zflight_srv00_mpc=>ts_flugkunde,
          ls_flugbuchungen TYPE zcl_zflight_srv00_mpc=>ts_flugbuchung.

    IF io_tech_request_context->get_source_entity_type_name( ) EQ 'Flugbuchung'.
      CALL METHOD io_tech_request_context->get_converted_source_keys
        IMPORTING
          es_key_values = ls_flugbuchungen.

      SELECT SINGLE customid FROM sbook
           INTO ls_flugkunde-customerid
           WHERE carrid = ls_flugbuchungen-carrid
             AND connid = ls_flugbuchungen-connid
             AND fldate = ls_flugbuchungen-fldate
             AND bookid = ls_flugbuchungen-bookid.
    ELSE.
      CALL METHOD io_tech_request_context->get_converted_keys
        IMPORTING
          es_key_values = ls_flugkunde.

      SELECT SINGLE
             id AS customerid name AS custname form street postbox AS pobox
             postcode city country AS countr country AS countr_iso region
             telephone AS phone email
          FROM scustom INTO CORRESPONDING FIELDS OF er_entity WHERE id = ls_flugkunde-customerid.
    ENDIF.
  ENDMETHOD.
