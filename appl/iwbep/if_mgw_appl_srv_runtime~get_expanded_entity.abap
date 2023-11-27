method /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.
    case iv_entity_name.
      when zcl_zflight_sh_mpc=>gc_flugkunde.
        data: ls_flugkunde     type zflight_sh_expanded,
              lt_flugbuchungen type zflight_sh_booking_tt.

        io_tech_request_context->get_converted_keys(
          importing
            es_key_values = ls_flugkunde
        ).

        select single
                   id as customerid, name as custname, form, street, postbox as pobox,
                   postcode, city, country as countr, country as countr_iso, region,
                   telephone as phone, email
                from scustom into corresponding fields of @ls_flugkunde
                where id = @ls_flugkunde-customerid.

        select carrid, bookid, connid, fldate, customid, class, order_date, counter,
            agencynum, cancelled, reserved, passname from sbook into table @lt_flugbuchungen
        where customid = @ls_flugkunde-customerid.

        loop at lt_flugbuchungen assigning field-symbol(<booking>).
          append <booking> to ls_flugkunde-flugbuchungen.
        endloop.

        copy_data_to_ref(
          exporting
            is_data = ls_flugkunde
          changing
            cr_data = er_entity ).

            append 'FLUGBUCHUNGEN' to et_expanded_tech_clauses. " NavProperty in UPPERCASE
    endcase.
  endmethod.
