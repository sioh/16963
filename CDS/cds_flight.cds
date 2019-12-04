@AbapCatalog.sqlViewName: 'CDS_FLIGHT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZCDS_FLIGHT'
define view ZCDS_FLIGHT as select from sflight {
    carrid     as CarrierId,
    connid     as ConnectionId,
    fldate     as FlightDate,
    currency_conversion(
      amount => price,
      source_currency => currency,
      target_currency => cast('EUR' as abap.cuky(5)),
      exchange_rate_date => fldate ) as Price,
    'EUR' as Currency,
    planetype  as PlaneType,
    seatsmax   as MaxSeats,
    seatsocc   as OccupiedSeats,
    division(seatsocc, seatsmax, 2) * 100 as UtilizationOverall,
    seatsmax - seatsmax_b - seatsmax_f as MaxSeatsEconomy,
    seatsocc - seatsocc_b - seatsocc_f as OccupiedSeatsEconomy,
    division((seatsocc - seatsocc_b - seatsocc_f), (seatsmax - seatsmax_b - seatsmax_f), 2) * 100 as UtilizationEconomy,
    seatsmax_b as MaxSeatsBusiness,
    seatsocc_b as OccupiedSeatsBusiness,
    division(seatsocc_b, seatsmax_b, 2) * 100 as UtilizationBusiness,
    seatsmax_f as MaxSeatsFirst,
    seatsocc_f as OccupiedSeatsFirst,
    division(seatsocc_f, seatsmax_f, 2) * 100 as UtilizationFirst
}
