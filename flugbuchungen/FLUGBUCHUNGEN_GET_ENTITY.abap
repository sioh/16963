METHOD flugbuchungset_get_entity.
DATA: ls_carrid TYPE /iwbep/s_mgw_name_value_pair,       
      ls_bookid TYPE /iwbep/s_mgw_name_value_pair,
      ls_connid TYPE /iwbep/s_mgw_name_value_pair,
      ls_fldate TYPE /iwbep/s_mgw_name_value_pair.
      
READ TABLE it_key_tab WITH KEY name = 'Carrid' INTO ls_carrid.
READ TABLE it_key_tab WITH KEY name = 'Bookid' INTO ls_bookid.
READ TABLE it_key_tab WITH KEY name = 'Connid' INTO ls_connid.
READ TABLE it_key_tab WITH KEY name = 'Fldate' INTO ls_fldate.

SELECT SINGLE carrid bookid connid fldate customid class order_date
    counter agencynum reserved cancelled passname
   FROM sbook INTO CORRESPONDING FIELDS OF er_entity
   WHERE carrid = ls_carrid-value AND
         bookid = ls_bookid-value AND
         connid = ls_connid-value AND
         fldate = ls_fldate-value.
 
ENDMETHOD.
