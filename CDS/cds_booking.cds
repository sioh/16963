@AbapCatalog.sqlViewName: 'CDS_BOOKING'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZCDS_BOOKING'
@OData.entitySet.name: 'FlugbuchungSet'
@OData.entityType.name: 'Flugbuchung'

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
