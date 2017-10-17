DATA: ls_entity TYPE BAPISCUDAT,
      lt_return TYPE TABLE OF BAPIRET2,
      ls_return TYPE BAPIRET2.

"Da der Datensatz lediglich identifiziert werden muss, reicht
"die Abfrage der Schlüssel durch den io_tech_request_context.
CALL METHOD io_tech_request_context->get_converted_keys
  IMPORTING
    es_key_values = ls_entity.

DELETE FROM scustom WHERE id = ls_entity-customerid.

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
