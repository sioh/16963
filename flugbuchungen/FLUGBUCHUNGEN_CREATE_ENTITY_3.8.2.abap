DATA: ls_entity TYPE sbook,
      ls_newentity TYPE BAPISBONEW,
      lv_carrid TYPE S_CARR_ID,
      lv_bookid TYPE S_BOOK_ID,
      lt_return TYPE TABLE OF BAPIRET2,
      ls_return TYPE BAPIRET2.

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
   RESERVE_ONLY = ls_entity-reserved
   booking_data = ls_newentity
*    TEST_RUN = ' '
  IMPORTING
    AIRLINEID = lv_carrid
    BOOKINGNUMBER = lv_bookid
*     TICKET_PRICE =
  TABLES
*   EXTENSION_IN =
    RETURN = lt_return
.
"Prüfung, ob der Rückgabeparameter Meldungen enthält,
"die keine Erfolgsmeldungen sind.
LOOP AT lt_return INTO ls_return WHERE type <> 'S'.
ENDLOOP
.
"Falls der Aufruf erfolgreich war, soll der neue
"Datensatz mit der erzeugten ID über den OData-Service
"ausgegeben werden.
IF ls_return IS INITIAL.
  MOVE-CORRESPONDING ls_entity TO er_entity.
  er_entity-carrid = lv_carrid.
  er_entity-bookid = lv_bookid.
ENDIF.
