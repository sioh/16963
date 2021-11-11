method flugbuchungen_get_entity.
  data(lt_keys) = io_tech_request_context->get_keys( ).

  er_entity-carrid = lt_keys[ name = 'CARRID' ]-value.
  er_entity-bookid = lt_keys[ name = 'BOOKID' ]-value.

  select single carrid, bookid, connid, fldate, customid, class, order_date,
          counter, agencynum, reserved, cancelled, passname
      from sbook into corresponding fields of @er_entity
      where carrid = @er_entity-carrid and
            bookid = @er_entity-bookid.

endmethod.
