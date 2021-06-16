# Hitobito Insieme


This hitobito wagon defines the organization hierarchy with groups and roles of Insieme Schweiz.

[![Build Status](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests/badge.svg)](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests.yml)

# Insieme Organization Hierarchy

    * Dachverein
      * Dachverein
        * PräsidentIn: [:contact_data]
        * Geschäftsführung: [:admin, :layer_and_below_full, :contact_data]
        * Sekretariat: [:layer_and_below_full, :contact_data]
        * Adressverwaltung: [:layer_and_below_full, :contact_data]
        * Controlling: [:admin, :layer_and_below_full, :contact_data]
      * Liste
        * Listenverwaltung: [:group_full]
        * Person: []
      * Gremium
        * Leitung: [:group_full, :contact_data]
        * Mitglied: [:group_read]
    * Regionalverein
      * Regionalverein
        * PräsidentIn: [:contact_data]
        * Geschäftsführung: [:layer_full, :contact_data]
        * Sekretariat: [:layer_full, :contact_data]
        * Adressverwaltung: [:layer_full, :contact_data]
        * Versandadresse: [:contact_data]
        * Rechnungsadresse: [:contact_data]
        * Controlling: [:contact_data]
      * Liste
        * Listenverwaltung: [:group_full]
        * Person: []
      * Gremium
        * Leitung: [:group_full, :contact_data]
        * Mitglied: [:group_read]
    * Externe Organisation
      * Externe Organisation
        * PräsidentIn: [:contact_data]
        * Geschäftsführung: [:layer_full, :contact_data]
        * Sekretariat: [:layer_full, :contact_data]
        * Adressverwaltung: [:layer_full, :contact_data]
        * Versandadresse: [:contact_data]
        * Rechnungsadresse: [:contact_data]
        * Controlling: [:contact_data]
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

## Vertragsperioden

In order to distinguish code that is valid only for certain years, we made the concept of contract periods (Vertragsperioden) explicit in the code. See [Vertragsperioden](doc/VERTRAGSPERIODEN.md) for a detailed description (in german, as is all domain-logic in this repo).
