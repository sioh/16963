# Beispiel für eine BATCH-Anfrage an den OData-Service 

## URL
`http(s)://<fqsn>:<port>/sap/opu/odata/sap/<service-name>/$batch`

## HTTP-Header
| Name         | Wert                             |
|--------------|----------------------------------|
| Content-Type | `multipart/mixed;boundary=batch` |
| Accept       | `application/json`               |

## Payload
```
--batch
Content-Type: multipart/mixed; boundary=changeset

--changeset
Content-Type: application/http
Content-Transfer-Encoding: binary

POST FlugkundeSet HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "Customerid":"",
  "Custname":"Beliebig",
  "Form":"Herr",
  "Street":"Irgendwo 9",
  "Pobox":"",
  "Postcode":"12345",
  "City":"Hinterwald",
  "Countr":"DE",
  "CountrIso":"DE",
  "Region":"",
  "Phone":"0123456789",
  "Email":"beliebig@beliebig.com"
}

--changeset
Content-Type: application/http
Content-Transfer-Encoding: binary

POST FlugkundeSet HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "Customerid":"",
  "Custname":"Beliebig II",
  "Form":"",
  "Street":"Irgendwo 10",
  "Pobox":"",
  "Postcode":"12345",
  "City":"Hinterwald",
  "Countr":"DE",
  "CountrIso":"DE",
  "Region":"",
  "Phone":"0123456789",
  "Email":"beliebig@beliebig.com"
}

--changeset--
--batch--
```
### Für multiple GET Request

```
--batch Content-Type: application/http
Content-Transfer-Encoding: binary

GET FlugbuchungSet?$top=5 HTTP/1.1
Accept: application/json


--batch
Content-Type: application/http
Content-Transfer-Encoding: binary

GET FlugkundeSet?$top=5 HTTP/1.1
Accept: application/json


--batch--
```
