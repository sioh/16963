@AbapCatalog.sqlViewName: 'CDS_CONNECT_SH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flugverbindungen'
@OData.entityType.name: 'Flugverbindung'
@OData.entitySet.name: 'Flugverbindungen'
define view zcds_connect_sh as select from spfli {
    key carrid,
    key connid,
    cityfrom,
    cityto,
    deptime,
    arrtime
}
