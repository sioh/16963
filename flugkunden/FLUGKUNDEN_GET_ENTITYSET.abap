  METHOD flugkundeset_get_entityset.
    DATA: ls_entity LIKE LINE OF et_entityset,
        lv_skip TYPE i,
        lv_top TYPE i,
        lv_osql_where_clause TYPE string,
        lt_orderby TYPE /iwbep/t_mgw_tech_order,
        ls_orderby TYPE /iwbep/s_mgw_tech_order,
        lv_orderby TYPE string,
        lv_order TYPE string.

    "get_filter liefert die Werte des $filter Parameters direkt zur Anwendung im OpenSQL.
    lv_osql_where_clause = io_tech_request_context->get_osql_where_clause( ).

    "get_orderby liefert die Werte des $orderby-Parameters zurück.
    lt_orderby = io_tech_request_context->get_orderby( ).

    "Falls der $orderby Parameter gesetzt wurde, wird ein String
    "für das OpenSQL-Statement gebaut.
    IF lt_orderby IS NOT INITIAL.
      LOOP AT lt_orderby INTO ls_orderby.
        lv_order = 'ASCENDING'.
        IF ls_orderby-order = 'desc'.
          lv_order = 'DESCENDING'.
        ENDIF.
        CONCATENATE lv_orderby ls_orderby-property lv_order
          INTO lv_orderby SEPARATED BY space.
      ENDLOOP.
    ELSE.
      lv_orderby = 'ID'.
    ENDIF.

    "has_count liefert abap_true zurück, wenn der $count Parameter
    "in der URI gesetzt ist.
    IF io_tech_request_context->has_count( ) = abap_true.
      "Die Elemente in es_response_context werden in die vom ODataService
      "verschickte Antwort it einbezogen, bzw. verändern sie.
      SELECT COUNT(*)
      FROM scustom
      WHERE (lv_osql_where_clause).

      es_response_context-count = sy-dbcnt.
      RETURN.
    ENDIF.

    lv_top = io_tech_request_context->get_top( ).

    lv_skip = io_tech_request_context->get_skip( ).
    IF lv_top IS NOT INITIAL.
      lv_top = lv_top + lv_skip.
    ENDIF.

    SELECT id AS customerid name AS custname form street postbox AS pobox
           postcode city country AS countr region telephone AS phone email
    FROM scustom INTO CORRESPONDING FIELDS OF TABLE et_entityset
    UP TO lv_top ROWS
    WHERE (lv_osql_where_clause)
    ORDER BY (lv_orderby).

    IF lv_skip IS NOT INITIAL.
      DELETE et_entityset TO lv_skip.
    ENDIF.

    "has_inlinecount liefert abap_true, wenn der $inlinecount Parameter
    "in der URI den Wert allpages hat.
    IF io_tech_request_context->has_inlinecount( ) = abap_true.
      es_response_context-inlinecount = sy-dbcnt.
    ENDIF.
  ENDMETHOD.
