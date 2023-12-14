  method flugbuchungen_get_entityset.
    data: lv_select     type string,
          lt_select     type string_table,
          lt_orderby    type /iwbep/t_mgw_tech_order,
          ls_orderby    type /iwbep/s_mgw_tech_order,
          lv_orderby    type string,
          lv_order      type string,
          lv_skip       type i,
          lv_top        type i,
          lo_filter     type ref to /iwbep/if_mgw_req_filter,
          lt_seloptions type /iwbep/t_mgw_select_option,
          ls_so_carrid  type /iwbep/t_cod_select_options,
          ls_so_cancel  type /iwbep/t_cod_select_options,
          ls_entity     type zcl_zflight_sh2_mpc=>ts_flugkunde.

    lt_select = io_tech_request_context->get_select_with_mandtry_fields( ).

    if lt_select is initial.
      "Falls kein $select mitgegeben wurde,
      "sollen folgende Felder gelesen werden
      lv_select = 'carrid bookid connid fldate customid class order_date counter agencynum reserved cancelled passname'.
      split lv_select at space into table lt_select.
    endif.

    if io_tech_request_context->get_source_entity_type_name( ) eq zcl_zflight_sh2_mpc=>gc_flugkunde.
      io_tech_request_context->get_converted_source_keys(
        importing
          es_key_values = ls_entity
      ).

      select (lt_select) from sbook into corresponding fields of table et_entityset
      where customid = ls_entity-customerid.
      return.
    endif.

    data(lv_osql_where_clause) = io_tech_request_context->get_osql_where_clause( ).

    lt_orderby = io_tech_request_context->get_orderby( ).

    if lt_orderby is not initial.
      loop at lt_orderby into ls_orderby.
        lv_order = 'ASCENDING'.
        if ls_orderby-order = 'desc'.
          lv_order = 'DESCENDING'.
        endif.
        concatenate lv_orderby ls_orderby-property lv_order into lv_orderby separated by space.
      endloop.
    endif.

    if io_tech_request_context->has_count( ) = abap_true.
      select count(*) from sbook into @data(lv_count).
      es_response_context-count = lv_count.
      return.
    endif.

    lv_skip = io_tech_request_context->get_skip( ).
    lv_top = io_tech_request_context->get_top( ).

    if lv_top is not initial.
      lv_top = lv_top + lv_skip.
    endif.

    select (lt_select) up to lv_top rows from sbook into corresponding fields of table et_entityset
      where (lv_osql_where_clause)
      order by (lv_orderby)
      "offset @lv_skip
      .

    if lv_skip is not initial.
      delete et_entityset to lv_skip.
    endif.

    if io_tech_request_context->has_inlinecount( ) = abap_true.
      es_response_context-inlinecount = sy-dbcnt.
    endif.
  endmethod.
