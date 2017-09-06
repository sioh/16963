method FLUGBUCHUNGSET_GET_ENTITYSET.
DATA: ls_entity LIKE LINE OF et_entityset,
    ls_headerdata TYPE BAPISBODAT,
    lv_skip TYPE i,
    lv_top type i,
    lv_select TYPE string,
    lt_select TYPE string_table,
    lo_filter TYPE REF TO /IWBEP/IF_MGW_REQ_FILTER,
    lt_seloptions TYPE /IWBEP/T_MGW_SELECT_OPTION,
    ls_so_carrid TYPE /IWBEP/S_MGW_SELECT_OPTION,
    ls_so_cancel TYPE /IWBEP/S_MGW_SELECT_OPTION,
    lt_orderby TYPE /IWBEP/T_MGW_TECH_ORDER,
    ls_orderby TYPE /IWBEP/S_MGW_TECH_ORDER,
    lv_orderby TYPE string,
    lv_order TYPE string.

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

"get_filter liefert die Werte des $filter Parameters in einem Objekt
CALL METHOD io_tech_request_context->get_filter
RECEIVING
  ro_filter = lo_filter.

"Von dem Filterobjekt lässt man sich eine Tabelle
"mit Select Options geben.
lt_seloptions = lo_filter->get_filter_select_options( ).

"Filter auf die Fluggesellschaft und das StornoKennzeichen werden
"gespeichert, andere Filter werden ignoriert.
READ TABLE lt_seloptions WITH TABLE KEY property = 'CARRID' INTO ls_so_carrid.
READ TABLE lt_seloptions WITH TABLE KEY property = 'CANCELLED' INTO ls_so_cancel.

"get_orderby liefert die Werte des $orderby-Parameters zurück.
CALL METHOD io_tech_request_context->get_orderby
RECEIVING
  rt_orderby = lt_orderby.

"Falls der $orderby Parameter gesetzt wurde, wird ein String
"für das SELECT-Statement gebaut.
IF lt_orderby IS NOT INITIAL.
LOOP AT lt_orderby INTO ls_orderby.
  lv_order = 'ASCENDING'.
  IF ls_orderby-order = 'desc'.
    lv_order = 'DESCENDING'.
  ENDIF.
  CONCATENATE lv_orderby ls_orderby-property lv_order INTO lv_orderby SEPARATED BY space.
ENDLOOP.
ENDIF.

IF ls_headerdata-customerid IS NOT INITIAL.
"Verwendung einer Tabelle statt fester Spaltenangabe,
"um dynamische Projektion zu ermöglichen.
SELECT (lt_select)
FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
WHERE customid = ls_headerdata-customerid
  AND carrid IN ls_so_carrid-select_options
  AND cancelled IN ls_so_cancel-select_options
ORDER BY (lv_orderby).

ELSE.

SELECT (lt_select)
FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
WHERE carrid IN ls_so_carrid-select_options
  AND cancelled IN ls_so_cancel-select_options
ORDER BY (lv_orderby).

ENDIF.

"has_count liefert abap_true zurück, wenn der $count Parameter
"in der URI gesetzt ist.
IF io_tech_request_context->has_count( ) = abap_true.
"Die Elemente in es_response_context werden in die vom ODataService
"verschickte Antwort it einbezogen, bzw. verändern sie.
es_response_context-count = sy-dbcnt.
ENDIF.

"has_inlinecount liefert abap_true, wenn der $inlinecount Parameter
"in der URI den Wert allpages hat.
IF io_tech_request_context->has_inlinecount( ) = abap_true.
es_response_context-inlinecount = sy-dbcnt.
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
