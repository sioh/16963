method flugbuchungen_get_entityset.
  data: ls_entity     like line of et_entityset,
        lv_skip       type i,
        lv_top        type i,
        lv_select     type string,
        lt_select     type string_table,
        lo_filter     type ref to /iwbep/if_mgw_req_filter,
        lt_seloptions type /iwbep/t_mgw_select_option,
        ls_so_carrid  type /iwbep/t_cod_select_options,
        ls_so_cancel  type /iwbep/t_cod_select_options,
        lt_orderby    type /iwbep/t_mgw_tech_order,
        ls_orderby    type /iwbep/s_mgw_tech_order,
        lv_orderby    type string,
        lv_order      type string.

  io_tech_request_context->get_converted_source_keys(
    importing
      es_key_values = ls_entity
  ).

  "get_select_with_mandtry_fields liefert die Werte des $select-Parameters
  "und die Schlüsselfelder des Entitätstyps.
  lt_select = io_tech_request_context->get_select_with_mandtry_fields( ).

  if lt_select is initial.
    "Falls kein $select mitgegeben wurde,
    "sollen folgende Felder gelesen werden
    lv_select = 'carrid bookid connid fldate customid class order_date counter agencynum reserved cancelled passname'.
    split lv_select at space into table lt_select.

  endif.

  "get_filter liefert die Werte des $filter Parameters in einem Objekt
  lo_filter = io_tech_request_context->get_filter( ).

  "Von dem Filterobjekt lässt man sich eine Tabelle
  "mit Select Options geben.
  lt_seloptions = lo_filter->get_filter_select_options( ).

  "Filter auf die Fluggesellschaft und das Stornokennzeichen werden
  "gespeichert, andere Filter werden ignoriert.
  ls_so_carrid = lt_seloptions[ property = 'CARRID' ]-select_options.
  ls_so_cancel = lt_seloptions[ property = 'CANCELLED' ]-select_options.

  "get_orderby liefert die Werte des $orderby-Parameters zurück.
  lt_orderby = io_tech_request_context->get_orderby( ).

  "Falls der $orderby Parameter gesetzt wurde, wird ein String
  "für das SELECT-Statement gebaut.
  if lt_orderby is not initial.
    loop at lt_orderby into ls_orderby.
      lv_order = 'ASCENDING'.
      if ls_orderby-order = 'desc'.
        lv_order = 'DESCENDING'.
      endif.
      concatenate lv_orderby ls_orderby-property lv_order into lv_orderby separated by space.
    endloop.
  endif.

  if ls_entity-customid is not initial.
    "Verwendung einer Tabelle statt fester Spaltenangabe,
    "um dynamische Projektion zu ermöglichen.
    select (lt_select)
    from sbook into corresponding fields of table et_entityset
    where customid = ls_entity-customid
      and carrid in ls_so_carrid
      and cancelled in ls_so_cancel
    order by (lv_orderby).

  else.

    select (lt_select)
    from sbook into corresponding fields of table et_entityset
    where carrid in ls_so_carrid
      and cancelled in ls_so_cancel
    order by (lv_orderby).

  endif.

  "has_count liefert abap_true zurück, wenn der $count Parameter
  "in der URI gesetzt ist.
  if io_tech_request_context->has_count( ) = abap_true.
    "Die Elemente in es_response_context werden in die vom ODataService
    "verschickte Antwort it einbezogen, bzw. verändern sie.
    es_response_context-count = sy-dbcnt.
  endif.

  "has_inlinecount liefert abap_true, wenn der $inlinecount Parameter
  "in der URI den Wert allpages hat.
  if io_tech_request_context->has_inlinecount( ) = abap_true.
    es_response_context-inlinecount = sy-dbcnt.
  endif.

  lv_skip = io_tech_request_context->get_skip( ).

  if lv_skip is not initial.
    delete et_entityset to lv_skip.
  endif.

  lv_top = io_tech_request_context->get_top( ).

  if lv_top is not initial.
    lv_top = lv_top + 1.
    delete et_entityset from lv_top.
  endif.

endmethod.
