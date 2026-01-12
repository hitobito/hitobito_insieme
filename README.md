# Hitobito Insieme


This hitobito wagon defines the organization hierarchy with groups and roles of Insieme Schweiz.

[![Build Status](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests/badge.svg)](https://github.com/hitobito/hitobito_insieme/actions/workflows/tests.yml)

# Insieme Organization Hierarchy

    * Dachverein
      * Dachverein
        * PräsidentIn: 2FA []  --  (Group::Dachverein::Praesident)
        * Vorstandsmitglied: 2FA []  --  (Group::Dachverein::Vorstandsmitglied)
        * Geschäftsführung: 2FA []  --  (Group::Dachverein::Geschaeftsfuehrung)
        * Sekretariat: 2FA []  --  (Group::Dachverein::Sekretariat)
        * Adressverwaltung: 2FA []  --  (Group::Dachverein::Adressverwaltung)
        * Controlling: 2FA []  --  (Group::Dachverein::Controlling)
        * Rechnungen: 2FA []  --  (Group::Dachverein::Invoicing)
        * IT Support: 2FA []  --  (Group::Dachverein::ItSupport)
        * Berechtigung Zv: 2FA [:layer_read, :contact_data]  --  (Group::Dachverein::BerechtigungZv)
        * Berechtigung Admin: 2FA [:admin, :layer_and_below_full, :contact_data, :manual_deletion]  --  (Group::Dachverein::BerechtigungAdmin)
        * Berechtigung Sekretariat: 2FA [:layer_and_below_full, :contact_data, :manual_deletion]  --  (Group::Dachverein::BerechtigungSekretariat)
        * Berechtigung Rechnungen: 2FA [:layer_and_below_read, :layer_and_below_finance]  --  (Group::Dachverein::BerechtigungRechnungen)
        * Extern: []  --  (Group::Dachverein::External)
      * Liste
        * Listenverwaltung: 2FA [:group_full]  --  (Group::DachvereinListe::Listenverwaltung)
        * Person: []  --  (Group::DachvereinListe::Person)
      * Gremium
        * Leitung: 2FA [:group_full, :contact_data]  --  (Group::DachvereinGremium::Leitung)
        * Mitglied: 2FA [:group_read]  --  (Group::DachvereinGremium::Mitglied)
      * Abonnemente
        * Einzelabo: []  --  (Group::DachvereinAbonnemente::Einzelabo)
        * Geschenkabo: []  --  (Group::DachvereinAbonnemente::Geschenkabo)
        * Gratisabo: []  --  (Group::DachvereinAbonnemente::Gratisabo)
    * Regionalverein < Regionalverein, Dachverein
      * Regionalverein
        * PräsidentIn: 2FA []  --  (Group::Regionalverein::Praesident)
        * Vorstandsmitglied: 2FA []  --  (Group::Regionalverein::Vorstandsmitglied)
        * Geschäftsführung: 2FA []  --  (Group::Regionalverein::Geschaeftsfuehrung)
        * Sekretariat: 2FA []  --  (Group::Regionalverein::Sekretariat)
        * Adressverwaltung: 2FA []  --  (Group::Regionalverein::Adressverwaltung)
        * Versandadresse: 2FA []  --  (Group::Regionalverein::Versandadresse)
        * Rechnungsadresse: 2FA []  --  (Group::Regionalverein::Rechnungsadresse)
        * Controlling: 2FA []  --  (Group::Regionalverein::Controlling)
        * Rechnungen: 2FA []  --  (Group::Regionalverein::Invoicing)
        * Extern: []  --  (Group::Regionalverein::External)
        * Berechtigung nur Lesen: 2FA [:layer_read]  --  (Group::Regionalverein::BerechtigungNurLesen)
        * Berechtigung Sekretariat: 2FA [:layer_full, :contact_data, :manual_deletion]  --  (Group::Regionalverein::BerechtigungSekretariat)
        * Berechtigung Rechnungen: 2FA [:layer_and_below_read, :finance]  --  (Group::Regionalverein::BerechtigungRechnungen)
      * Liste
        * Listenverwaltung: 2FA [:group_full]  --  (Group::RegionalvereinListe::Listenverwaltung)
        * Person: []  --  (Group::RegionalvereinListe::Person)
      * Gremium
        * Leitung: 2FA [:group_full, :contact_data]  --  (Group::RegionalvereinGremium::Leitung)
        * Mitglied: 2FA [:group_read]  --  (Group::RegionalvereinGremium::Mitglied)
    * Externe Organisation < Externe Organisation, Dachverein
      * Externe Organisation
        * PräsidentIn: 2FA []  --  (Group::ExterneOrganisation::Praesident)
        * Vorstandsmitglied: 2FA []  --  (Group::ExterneOrganisation::Vorstandsmitglied)
        * Geschäftsführung: 2FA []  --  (Group::ExterneOrganisation::Geschaeftsfuehrung)
        * Sekretariat: 2FA []  --  (Group::ExterneOrganisation::Sekretariat)
        * Adressverwaltung: 2FA []  --  (Group::ExterneOrganisation::Adressverwaltung)
        * Versandadresse: 2FA []  --  (Group::ExterneOrganisation::Versandadresse)
        * Rechnungsadresse: 2FA []  --  (Group::ExterneOrganisation::Rechnungsadresse)
        * Controlling: 2FA []  --  (Group::ExterneOrganisation::Controlling)
        * Rechnungen: 2FA []  --  (Group::ExterneOrganisation::Invoicing)
        * Extern: []  --  (Group::ExterneOrganisation::External)
        * Berechtigung nur Lesen: 2FA [:layer_read]  --  (Group::ExterneOrganisation::BerechtigungNurLesen)
        * Berechtigung Sekretariat: 2FA [:layer_full, :contact_data, :manual_deletion]  --  (Group::ExterneOrganisation::BerechtigungSekretariat)
        * Berechtigung Rechnungen: 2FA [:layer_and_below_read, :finance]  --  (Group::ExterneOrganisation::BerechtigungRechnungen)
      * Liste
        * Listenverwaltung: 2FA [:group_full]  --  (Group::ExterneOrganisationListe::Listenverwaltung)
        * Person: []  --  (Group::ExterneOrganisationListe::Person)
      * Gremium
        * Leitung: 2FA [:group_full, :contact_data]  --  (Group::ExterneOrganisationGremium::Leitung)
        * Mitglied: 2FA [:group_read]  --  (Group::ExterneOrganisationGremium::Mitglied)
    * Global
      * Aktivmitglieder
        * Aktivmitglied: []  --  (Group::Aktivmitglieder::Aktivmitglied)
        * Aktivmitglied ohne Abo: []  --  (Group::Aktivmitglieder::AktivmitgliedOhneAbo)
        * Zweitmitgliedschaft: []  --  (Group::Aktivmitglieder::Zweitmitgliedschaft)
      * Passivmitglieder
        * Passivmitglied: []  --  (Group::Passivmitglieder::Passivmitglied)
        * Passivmitglied mit Abo: []  --  (Group::Passivmitglieder::PassivmitgliedMitAbo)
      * Kollektivmitglieder
        * Kollektivmitglied: []  --  (Group::Kollektivmitglieder::Kollektivmitglied)
        * Kollektivmitglied mit Abo: []  --  (Group::Kollektivmitglieder::KollektivmitgliedMitAbo)

    (Output of rake app:hitobito:roles)

## Featureperioden

In order to distinguish code that is valid only for certain years, we made the concept of contract periods explicit in the code. Each contract period can be subdivided into several periods where a certain feature/implementation is valid. Therefore, we call them Featureperiode. See [Featureperioden](doc/FEATUREPERIODEN.md) for a detailed description (in german, as is all domain-logic in this repo).
