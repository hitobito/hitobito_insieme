
# Adressen

Zusätzlich zur Hauptadresse existieren auf der Person

- Korrespondenzadresse Allgemein  (correspondence_general)
- Korrespondenzadresse Kurs  (correspondence_course)
- Rechnungsadresse Allgemein  (billling_general)
- Rechnungsadresse Kurs  (billling_course)

Damit können Adressinformationen aber auch Anrede, Namen und Firma spezfisch
vergeben werden. Siehe dazu auch `Person::AddressNormalizer` sowie
`contactable/address_fields`.

Während auf der Kursteilnahme können nur die Kursadressen bearbeitet werden,
können auf der Person alle Felder bearbeitet werden.

Verwendet werden die Felder dann wie folgt:

- Der Etikettendruck kann für spezifische Adressen gemacht werden.
- Im Personen Export (Alle Spalten) sind die verschiedenen Adressen enthalten.
- Rechnungen werden an die Rechnungs Allgemein adressiert.

