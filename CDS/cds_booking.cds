define view ZCDS_BOOKING as select from sbook   {
    key carrid,
    key connid,
    key fldate,
    key bookid,
    customid,
    invoice,
    class,
    order_date,
    cancelled,
    reserved,
    passname
}
