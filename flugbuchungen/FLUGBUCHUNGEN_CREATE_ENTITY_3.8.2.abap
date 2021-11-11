method flugbuchungen_create_entity.
  data: ls_entity    type zcl_zflight_00_mpc=>ts_flugbuchung,
        ls_newentity type bapisbonew,
        lv_carrid    type s_carr_id,
        lv_bookid    type s_book_id,
        lt_return    type table of bapiret2,
        ls_return    type bapiret2.

  "io_data_provider->read_entry_data liefert eine
  "Struktur des Typs sbook zurück, die werte für die
  "Erstellung des Datensatzes enthält.
  io_data_provider->read_entry_data(
    importing
      es_data = ls_entity
  ).
* CATCH /iwbep/cx_mgw_tech_exception. "

  "Die vom BAPI genutzte Struktur unterscheidet sich von
  "der des Services, daher müssen die Felder hier manuell
  "gemappt werden.
  ls_newentity = value #(
      agencynum  = ls_entity-agencynum
      airlineid  = ls_entity-carrid
      class      = ls_entity-class
      connectid  = ls_entity-connid
      counter    = ls_entity-counter
      customerid = ls_entity-customid
      flightdate = ls_entity-fldate
      passbirth  = ls_entity-passbirth
      passform   = ls_entity-passform
      passname   = ls_entity-passname
  ).

  "Aufruf des BAPIs zum Erzeugen einer neuen Buchung.
  call function 'BAPI_FLBOOKING_CREATEFROMDATA'
    exporting
      reserve_only  = ls_entity-reserved
      booking_data  = ls_newentity
*       TEST_RUN      = ' '
    importing
      airlineid     = lv_carrid
      bookingnumber = lv_bookid
*       TICKET_PRICE  =
    tables
*       EXTENSION_IN  =
      return        = lt_return.
  "Prüfung, ob der Rückgabeparameter Meldungen enthält,
  "die keine Erfolgsmeldungen sind.
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
  else.
    "Falls der Aufruf erfolgreich war, soll der neue
    "Datensatz mit der erzeugten ID über den OData-Service
    "ausgegeben werden.
    move-corresponding ls_entity to er_entity.
    er_entity-carrid = lv_carrid.
    er_entity-bookid = lv_bookid.
  endif.
endmethod.
