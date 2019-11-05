  METHOD flugbuchungset_get_entityset.
    DATA: ls_entity LIKE LINE OF et_entityset,
        ls_flugkunde TYPE zcl_zflight_srv00_mpc=>ts_flugkunde,
        lv_skip TYPE i,
        lv_top TYPE i,
        lv_select TYPE string,
        lt_select TYPE string_table,
        lv_osql_where_clause TYPE string,
        lt_orderby TYPE /iwbep/t_mgw_tech_order,
        ls_orderby TYPE /iwbep/s_mgw_tech_order,
        lv_orderby TYPE string,
        lv_order TYPE string.

    IF io_tech_request_context->get_source_entity_type_name( ) EQ 'Flugkunde'.
      CALL METHOD io_tech_request_context->get_converted_source_keys
        IMPORTING
          es_key_values = ls_flugkunde.

      "Verwendung einer Tabelle statt fester Spaltenangabe,
      "um dynamische Projektion zu ermöglichen.
      SELECT (lt_select)
      FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
      WHERE customid = ls_flugkunde-customerid
      ORDER BY (lv_orderby).
    ELSE.
      "get_select_with_mandtry_fields liefert die Werte des $selectParameters
      "und die Schlüsselfelder des Entitätstyps.
      lt_select = io_tech_request_context->get_select_with_mandtry_fields( ).

      IF lt_select IS INITIAL.
        "Falls kein $select mitgegeben wurde,
        "sollen folgende Felder gelesen werden
        lv_select = 'carrid bookid connid fldate customid class order_date counter agencynum reserved cancelled passname'.
        SPLIT lv_select AT space INTO TABLE lt_select.
      ENDIF.

      "has_count liefert abap_true zurück, wenn der $count Parameter
      "in der URI gesetzt ist.
      IF io_tech_request_context->has_count( ) = abap_true.
        "Die Elemente in es_response_context werden in die vom ODataService
        "verschickte Antwort it einbezogen, bzw. verändern sie.
        SELECT COUNT(*)
        FROM sbook
        WHERE (lv_osql_where_clause).

        es_response_context-count = sy-dbcnt.
        RETURN.
      ENDIF.

      "get_filter liefert die Werte des $filter Parameters in einem Objekt
      lv_osql_where_clause = io_tech_request_context->get_osql_where_clause( ).

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

      lv_top = io_tech_request_context->get_top( ).

      lv_skip = io_tech_request_context->get_skip( ).
      IF lv_top IS NOT INITIAL.
        lv_top = lv_top + lv_skip.
      ENDIF.

      SELECT (lt_select)
      FROM sbook INTO CORRESPONDING FIELDS OF TABLE et_entityset
      UP TO lv_top ROWS
      WHERE (lv_osql_where_clause)
      ORDER BY (lv_orderby).

      "has_inlinecount liefert abap_true, wenn der $inlinecount Parameter
      "in der URI den Wert allpages hat.
      IF io_tech_request_context->has_inlinecount( ) = abap_true.
        es_response_context-inlinecount = sy-dbcnt.
      ENDIF.

      IF lv_skip IS NOT INITIAL.
        DELETE et_entityset TO lv_skip.
      ENDIF.
    ENDIF.
  ENDMETHOD.
