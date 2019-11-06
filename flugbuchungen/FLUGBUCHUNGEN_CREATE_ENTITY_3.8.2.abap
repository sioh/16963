  METHOD flugbuchungset_create_entity.
    DATA: ls_entity TYPE zcl_zgw_flugkunden_001_mpc=>ts_flugbuchung,
          ls_newentity TYPE bapisbonew,
          lv_carrid TYPE s_carr_id,
          lv_bookid TYPE s_book_id,
          lt_return TYPE TABLE OF bapiret2,
          ls_return TYPE bapiret2.

    "io_data_provider->read_entry_data liefert eine
    "Struktur des Typs sbook zurück, die werte für die
    "Erstellung des Datensatzes enthält.
    CALL METHOD io_data_provider->read_entry_data
      IMPORTING
        es_data = ls_entity.
* CATCH /iwbep/cx_mgw_tech_exception. "

    "Die vom BAPI genutzte Struktur unterscheidet sich von
    "der des Services, daher müssen die Felder hier manuell
    "gemappt werden.
    ls_newentity-agencynum = ls_entity-agencynum.
    ls_newentity-airlineid = ls_entity-carrid.
    ls_newentity-class = ls_entity-class.
    ls_newentity-connectid = ls_entity-connid.
    ls_newentity-counter = ls_entity-counter.
    ls_newentity-customerid = ls_entity-customid.
    ls_newentity-flightdate = ls_entity-fldate.
    ls_newentity-passbirth = ls_entity-passbirth.
    ls_newentity-passform = ls_entity-passform.
    ls_newentity-passname = ls_entity-passname.

    "Aufruf des BAPIs zum Erzeugen einer neuen Buchung.
    CALL FUNCTION 'BAPI_FLBOOKING_CREATEFROMDATA'
      EXPORTING
        reserve_only  = ls_entity-reserved
        booking_data  = ls_newentity
*       TEST_RUN      = ' '
      IMPORTING
        airlineid     = lv_carrid
        bookingnumber = lv_bookid
*       TICKET_PRICE  =
      TABLES
*       EXTENSION_IN  =
        return        = lt_return.
    "Prüfung, ob der Rückgabeparameter Meldungen enthält,
    "die keine Erfolgsmeldungen sind.
    READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.

    IF ls_return IS NOT INITIAL.
      "Ist ls_return gesetzt, werden alle wiedergegebenen Fehler
      "an den Message-Container gegeben und eine Ausnahme
      "geworfen, die all diese Meldungen enthält und die letzte
      "Fehlermeldung als übergeordneten Text anzeigt.
      mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = mo_context->get_message_container( )
          message           = ls_return-message.
    ELSE.
      "Falls der Aufruf erfolgreich war, soll der neue
      "Datensatz mit der erzeugten ID über den OData-Service
      "ausgegeben werden.
      MOVE-CORRESPONDING ls_entity TO er_entity.
      er_entity-carrid = lv_carrid.
      er_entity-bookid = lv_bookid.
    ENDIF.
  ENDMETHOD.
