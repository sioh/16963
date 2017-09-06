DATA ls_entity TYPE sbook.

"Abfrage der Daten aus dem Request.
CALL METHOD io_tech_request_context->get_converted_keys
  IMPORTING
    es_key_values = ls_entity.

"Aufruf des BAPIs zur Bestätigung der Reservierung.
CALL FUNCTION 'BAPI_FLBOOKING_CONFIRM'
  EXPORTING
    airlineid = ls_entity-carrid
    bookingnumber = ls_entity-bookid
*    TEST_RUN = ' '
*    TABLES
* RETURN =
.

"Auslesen des geänderten Datensatzes von der Datenbank.
SELECT SINGLE * FROM sbook INTO CORRESPONDING FIELDS OF er_entity
WHERE carrid = ls_entity-carrid
  AND bookid = ls_entity-bookid.
