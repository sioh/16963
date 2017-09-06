"Variable zum Lesen der Import-Parameter
DATA: ls_parameter TYPE /iwbep/s_mgw_name_value_pair.
"Unterscheidung verschiedener Funktionsimporte
CASE iv_action_name.
  "Wenn der Funktionsimport GetBookSum aufgerufen wurde
  WHEN 'GetBookSum'.
    "Definition einer Struktur für den Rückgabewert
    TYPES: BEGIN OF lty_booksum,
              customerid TYPE S_CUSTOMER,
              sum TYPE S_L_CUR_PR,
              currency TYPE S_CURRCODE,
           END OF lty_booksum.
    DATA: ls_booksum TYPE lty_booksum,
          ls_tmpsum TYPE lty_booksum.
    "Lese die mitgegebene Kundennummer und trage sie in die
    "Ergebnis-Struktur ein.
    READ TABLE it_parameter INTO ls_parameter WITH KEY name = 'CustomerID'.
    IF sy-subrc eq 0.
      ls_booksum-customerid = ls_parameter-value.
    ENDIF.

    "Lese die mitgegebene Währung und trage sie in die
    "Ergebnis-Struktur ein.
    READ TABLE it_parameter INTO ls_parameter WITh KEY name = 'Currency'.
    IF sy-subrc eq 0.
      ls_booksum-currency = ls_parameter-value.
    ENDIF.
    "Summiere alle Buchungsbeträge des Kunden, gruppiert nach der Währung auf.
    SELECT customid SUM( loccuram ) loccurkey FROM sbook INTO ls_tmpsum
      WHERE customid eq ls_booksum-customerid
      GROUP BY customid loccurkey.
      "Rechne den Betrag in die angegebene Währung um.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          date = sy-datum
          foreign_amount = ls_tmpsum-sum
          foreign_currency = ls_tmpsum-currency
          local_currency = ls_booksum-currency
        IMPORTING
          LOCAL_AMOUNT = ls_tmpsum-sum.

      IF sy-subrc <> 0.
      * Implement suitable error handling here
      ENDIF.
      "Füge den Betrag zum Gesamtbetrag hinzu.
      ls_booksum-sum = ls_booksum-sum + ls_tmpsum-sum.
    ENDSELECT.
    "Übergebe die Ergebnis-Struktur an den Export-Parameter.
    copy_data_to_ref(
      EXPORTING
        is_data = ls_booksum
      CHANGING
        cr_data = er_data
    ).
ENDCASE.
