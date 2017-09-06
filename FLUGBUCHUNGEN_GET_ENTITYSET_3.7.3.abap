DATA: ls_entity LIKE LINE OF et_entityset,
      ls_headerdata TYPE BAPISBODAT,
      lv_skip TYPE i,
      lv_top type i.

CALL METHOD io_tech_request_context->get_converted_source_keys
  IMPORTING
    es_key_values = ls_headerdata.

IF ls_headerdata-customerid IS NOT INITIAL.
  "Verwendung einer Tabelle statt fester Spaltenangabe,
  "um dynamische Projektion zu ermöglichen.
  SELECT carrid bookid connid fldate customid class order_date
         counter agencynum reserved cancelled passname
  FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
  WHERE customid = ls_headerdata-customerid
  ORDER BY carrid bookid.

ELSE.

  SELECT carrid bookid connid fldate customid class order_date
         counter agencynum reserved cancelled passname
  FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
  ORDER BY carrid bookid.

ENDIF.

"has_count liefert abap_true zurück, wenn der $count Parameter
"in der URI gesetzt ist.
IF io_tech_request_context->has_count( ) = abap_true.
  "Die Elemente in es_response_context werden in die vom ODataService
  "verschickte Antwort it einbezogen, bzw. verändern sie.
  es_response_context-count = sy-dbcnt.
ENDIF.

CALL METHOD io_tech_request_context->get_skip
  RECEIVING
    rv_skip = lv_skip.

IF lv_skip IS NOT INITIAL.
  DELETE et_entityset TO lv_skip.
ENDIF.

CALL METHOD io_tech_request_context->get_top
  RECEIVING
    rv_top = lv_top.

IF lv_top IS NOT INITIAL.
  lv_top = lv_top + 1.
  DELETE et_entityset FROM lv_top.
ENDIF.
