@AbapCatalog.sqlViewName: 'CDS_CUSTOMER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZCDS_CUSTOMER'
@OData.entitySet.name: 'FlugkundeSet'
@OData.entityType.name: 'Flugkunde'
define view ZCDS_CUSTOMER as select from scustom association [1..*] to ZCDS_BOOKING as booking on  booking.customid = $projection.id {
    key id,
    name,
    form,
    street,
    city,
    postcode,
    country,
    region,
    booking
}
