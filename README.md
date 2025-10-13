# Hitobito Insieme


This hitobito wagon defines the organization hierarchy with groups and roles of Insieme Schweiz.

[![Build Status](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests/badge.svg)](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests.yml)

# Insieme Organization Hierarchy

    * Dachverein
      * Dachverein
        * PräsidentIn: [:layer_read, :contact_data]
        * Vorstandsmitglied: [:layer_read]
        * Geschäftsführung: [:admin, :layer_and_below_full, :contact_data, :impersonation, :finance]
        * Sekretariat: [:layer_and_below_full, :contact_data, :manual_deletion]
        * Adressverwaltung: [:layer_and_below_full, :contact_data, :manual_deletion]
        * Controlling: [:admin, :layer_and_below_full, :contact_data]
        * Rechnungen: [:layer_and_below_read, :finance]
        * IT Support: [:admin, :layer_and_below_full, :impersonation]
        * Extern: []
      * Liste
        * Listenverwaltung: [:group_full]
        * Person: []
      * Gremium
        * Leitung: [:group_full, :contact_data]
        * Mitglied: [:group_read]
      * Abonnemente
        * Einzelabo: []
        * Geschenkabo: []
        * Gratisabo: []
    * Regionalverein
      * Regionalverein
        * PräsidentIn: [:layer_read, :contact_data]
        * Vorstandsmitglied: [:layer_read]
        * Geschäftsführung: [:layer_full, :contact_data, :manual_deletion]
        * Sekretariat: [:layer_full, :contact_data, :manual_deletion]
        * Adressverwaltung: [:layer_full, :contact_data, :manual_deletion]
        * Versandadresse: [:contact_data]
        * Rechnungsadresse: [:contact_data]
        * Controlling: [:contact_data]
        * Rechnungen: [:layer_and_below_read, :finance]
        * Extern: []
      * Liste
        * Listenverwaltung: [:group_full]
        * Person: []
      * Gremium
        * Leitung: [:group_full, :contact_data]
        * Mitglied: [:group_read]
    * Externe Organisation
      * Externe Organisation
        * PräsidentIn: [:layer_read, :contact_data]
        * Vorstandsmitglied: [:layer_read]
        * Geschäftsführung: [:layer_full, :contact_data, :manual_deletion]
        * Sekretariat: [:layer_full, :contact_data, :manual_deletion]
        * Adressverwaltung: [:layer_full, :contact_data, :manual_deletion]
        * Versandadresse: [:contact_data]
        * Rechnungsadresse: [:contact_data]
        * Controlling: [:contact_data]
        * Rechnungen: [:layer_and_below_read, :finance]
        * Extern: []
      * Liste
        * Listenverwaltung: [:group_full]
        * Person: []
      * Gremium
        * Leitung: [:group_full, :contact_data]
        * Mitglied: [:group_read]
    * Global
      * Aktivmitglieder
        * Aktivmitglied: []
        * Aktivmitglied ohne Abo: []
        * Zweitmitgliedschaft: []
      * Passivmitglieder
        * Passivmitglied: []
        * Passivmitglied mit Abo: []
      * Kollektivmitglieder
        * Kollektivmitglied: []
        * Kollektivmitglied mit Abo: []

    (Output of rake app:hitobito:roles)

## Featureperioden

In order to distinguish code that is valid only for certain years, we made the concept of contract periods explicit in the code. Each contract period can be subdivided into several periods where a certain feature/implementation is valid. Therefore, we call them Featureperiode. See [Featureperioden](doc/FEATUREPERIODEN.md) for a detailed description (in german, as is all domain-logic in this repo).
