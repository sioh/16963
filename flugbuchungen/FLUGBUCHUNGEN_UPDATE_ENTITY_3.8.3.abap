method flugbuchungen_update_entity.
  data: ls_entity type sbook,
        lt_return type table of bapiret2,
        ls_return type bapiret2.
  "Abfrage der Daten aus dem Request.
  io_tech_request_context->get_converted_keys(
    importing
      es_key_values = ls_entity ).

  "Aufruf des BAPIs zur Bestätigung der Reservierung.
  call function 'BAPI_FLBOOKING_CONFIRM'
    exporting
      airlineid     = ls_entity-carrid
      bookingnumber = ls_entity-bookid
*       TEST_RUN      = ' '
    tables
      return        = lt_return.
  if lt_return is not initial.
    "Ist ls_return gesetzt, werden alle wiedergegebenen Fehler
    "an den Message-Container gegeben und eine Ausnahme
    "geworfen, die all diese Meldungen enthält und die letzte
    "Fehlermeldung als übergeordneten Text anzeigt.
    mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
    raise exception type /iwbep/cx_mgw_busi_exception
      exporting
        message_container = mo_context->get_message_container( )
        message           = ls_return-message.
  endif.
  "Auslesen des geänderten Datensatzes von der Datenbank.
  select single * from sbook into corresponding fields of er_entity
  where carrid = ls_entity-carrid
    and bookid = ls_entity-bookid.

endmethod.
