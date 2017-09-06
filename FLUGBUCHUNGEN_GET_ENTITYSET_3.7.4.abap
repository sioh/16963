DATA: ls_entity LIKE LINE OF et_entityset,
      ls_headerdata TYPE BAPISBODAT,
      lv_skip TYPE i,
      lv_top type i,
      lv_select TYPE string,
      lt_select TYPE string_table.

CALL METHOD io_tech_request_context->get_converted_source_keys
  IMPORTING
    es_key_values = ls_headerdata.

"get_select_with_mandtry_fields liefert die Werte des $selectParameters
"und die Schlüsselfelder des Entitätstyps.
CALL METHOD io_tech_request_context->get_select_with_mandtry_fields
  RECEIVING
    rt_select = lt_select.

IF lt_select IS INITIAL.
  "Falls kein $select mitgegeben wurde,
  "sollen folgende Felder gelesen werden
  lv_select = 'carrid bookid connid fldate customid class order_date counter agencynum reserved cancelled passname'.
  SPLIT lv_select AT space INTO TABLE lt_select.

ENDIF.

IF ls_headerdata-customerid IS NOT INITIAL.
  "Verwendung einer Tabelle statt fester Spaltenangabe,
  "um dynamische Projektion zu ermöglichen.
  SELECT (lt_select)
  FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
  WHERE customid = ls_headerdata-customerid
  ORDER BY carrid bookid.

ELSE.

  SELECT (lt_select)
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
