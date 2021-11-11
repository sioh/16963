method flugbuchungen_delete_entity.
  data: ls_entity type sbook,
        lt_return type table of bapiret2,
        ls_return type bapiret2.

  "Da der Datensatz lediglich identifiziert werden muss, reicht
  "die Abfrage der Schlüssel durch den io_tech_request_context.
  io_tech_request_context->get_converted_keys(
    importing
      es_key_values = ls_entity
  ).

  "Aufruf des BAPIs zur Stornierung.
  call function 'BAPI_FLBOOKING_CANCEL'
    exporting
      airlineid     = ls_entity-carrid
      bookingnumber = ls_entity-bookid
*       TEST_RUN      = ' '
    tables
      return        = lt_return.

  "Falls die zurückgegebene Meldungstabelle eine Fehlermeldung
  "(Typ E) enthält wird ls_return gesetzt.
  read table lt_return into ls_return with key type = 'E'.

  if ls_return is not initial.
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

endmethod.
