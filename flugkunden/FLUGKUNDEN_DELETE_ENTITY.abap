DATA: ls_entity TYPE BAPISCUDAT.

"Da der Datensatz lediglich identifiziert werden muss, reicht
"die Abfrage der Schlüssel durch den io_tech_request_context.
CALL METHOD io_tech_request_context->get_converted_keys
  IMPORTING
    es_key_values = ls_entity.

DELETE FROM scustom WHERE id = ls_entity-customerid.
