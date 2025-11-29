# Featureperiodenanpassungen und -wechsel

## Motivation und Hintergrund

insieme Schweiz als Dachorganisation organisiert mehrere Vereine. In diesem Zusammenhang werden
Daten der Vereine erhoben und ausgewertet. Diese Auswertung ist an vertragliche Grundlagen gebunden,
welche sich regelmässig ändern. Eine solche Vertragsperiode dauert üblicherweise vier Jahre, wobei die
von 2015 fünf Jahre umfasste und bei der Vertragsperiode 2020 schon für das nächste Jahr Anpassungen
erwartet werden. Anpassungen an der Datenerhebung und Auswertung gelten dabei immer für ein
Kalenderjahr.

## Implementierung

Es gibt einen Featureperioden-Dispatcher, der aufgrund des Kalenderjahres entsprechende Domainklassen
und Viewtemplates auswählt.

In allen Beispielen hier gehe ich von der Vertragsperiode 2020 aus. Die Ziffer ist immer das
beginnende Jahr der Vertragsperiode. Die gängige Abkürzung für Vertragsperiode ist "VP", jeweils
nach der Konvention der jeweiligen Verwendung.

### Views

Um Formulare und Auswertungsergebnisse anzupassen, wird der Viewpath so angepasst, dass die gewählte
Vertragsperiode vorangestellt wird. Die Views sind z.B. in `app/views/fp2020` zu finden. In diesem
Verzeichnis gelten dann wieder die normalen Regeln, um den richtigen View zu finden. Damit
überschreiben die Templates in dem jeweiligen Verzeichnis die Templates in `app/views` des Wagons
und im hitobito-Core.

Um diese für einen Controller zu aktiveren, muss nur das Modul `Featureperioden::Views` inkludiert
werden.

Es wid jeweils **nur eine einzelne** Vertragsperiode in den Viewpath des aktuellen Request aufgenommen.

### Domainklassen

#### Allgemeine Struktur

Alle reporting-bezogenen Anpassungen werden in Namespaces der jeweiligen Vertragsperiode (z.B.
`Fp2015`, `Fp2020`, `Fp2022`, …) gekapselt. Die bestehenden Perioden bis und mit `Fp2022` wurden
noch nach dem alten Muster (vollständiges Kopieren und Zurückkopieren von Klassen) erstellt und
bleiben unverändert bestehen.

#### Neue Featureperiode

Seit `Fp2024` genügt es, eine leere Hülle für die neue VP anzulegen, da die Domainklassen
über den Fallback-Mechanismus automatisch aus älteren FPs wiederverwendet werden:
- `app/domain/fpYYYY.rb` mit `module FpYYYY; end`
- ein leeres Verzeichnis `app/domain/fpYYYY/` (optional mit Unterordnern wie `export/`, `cost_accounting/`)

Anschliessend wird der Dispatcher (`app/domain/vertragsperioden/dispatcher.rb`) um das neue Jahr in 
`KNOWN_BASE_YEARS` ergänzt.
Ab dort kann die normale Entwicklung in der neuen VP erfolgen (neue Klassen oder Overrides nur dort anlegen,
wo sich tatsächlich etwas ändert).

Dafür existiert ein (überarbeiteter) Rake-Task:
`rake fp:new[YEAR]`

Dieser erzeugt:
- die Moduldatei `app/domain/fpYYYY.rb`
- das leere Verzeichnis `app/domain/fpYYYY/`
- leere Spec-Skeletons (`spec/domain/fpYYYY/`, `spec/models/fpYYYY/`)
- kopierte Views (`app/views/fpYYYY`), da Views weiterhin strikt pro VP überschrieben werden
- und passt die `KNOWN_BASE_YEARS` im Dispatcher an.

Ein vollständiges Kopieren des vorherigen FP-Verzeichnisses ist nicht mehr notwendig.

#### Fallback-Mechanismus

Mit der Methode `fp_class` wird eine Domainklasse für ein bestimmtes Jahr ermittelt.  
Neu gilt dabei:  
- Es wird zuerst im Namespace der aktuellen VP gesucht.  
- Falls dort die Klasse nicht existiert, wird **rückwärts** in älteren VPs gesucht, bis sie gefunden wird.  
- Es erfolgt **keine Vorwärts-Suche** in neueren VPs.

Der Helper `fp_class` ist verfügbar, wenn man in die entsprechende Klasse das Modul
`Featureperioden::Domain` inkludiert. Die Methode `year` muss implemetiert sein, entweder explizit
oder implizit im Fall von `ActiveRecord`-Subklassen.

Der Helper gibt nur die Klasse im korrekten Namespace zurück, da die konkrete Verwendung nicht
vorhergesehen werden kann.

Beispiel: Für das Jahr 2025 (VP2024) sucht `fp_class("Export::Xlsx")` zuerst in `Fp2024::Export::Xlsx`, 
fällt bei Nichtvorhandensein auf `Fp2022::Export::Xlsx` zurück, danach ggf. auf `Fp2020` usw.

#### Neue Klassen und Overrides

- **Override einer bestehenden Klasse**:  
  Neue Implementierung in `fp2024/`, die von der alten Klasse erbt, z.B.:  
  ```ruby
  class Fp2024::CourseReporting::ClientStatistics < Fp2022::CourseReporting::ClientStatistics
    # Überschriebene Methoden oder neue Logik
  end

Subclassing wird nicht nur bei tiefgreifenden strukturellen Änderungen eingesetzt, sondern auch, wenn kleine Anpassungen (z. B. Policy-Wiring, siehe unten) innerhalb einer VP erforderlich sind. Ziel ist immer, die Änderungen sauber im Namespace der aktuellen VP zu kapseln und ältere VPs unverändert zu lassen.“

- **Neue Klasse ab einer VP**
  Direkt in `fp2024/` anlegen. Ältere VPs sehen diese Klasse nicht.

#### Forward-Limitierung
Da keine Vorwärts-Suche exisitiert, schlagen Zugriffe auf neue Klassen in älteren VPs mit `NameError` fehl.
Falls **shared code** über alle VPs versucht, auf neue Klasen zuzugreifen, gibt es zwei Lösungen:
- Guard im Code (z.B. durch Jahr-Check), oder
- Back-Copying von neuen Klassen als Stub-Klasse in ältere VPs.
Diese Stub-Klassen tun nichts, ausser die neue Klasse in alten VPs zu definieren, um den `NameError` zu vermeiden.

#### `domain_class` Methode in dispatcher.rb (strikte Klassenresolution)
Diese Methode nutzt immer noch eine strikte Klassen-Ermittlung (kein Fallback-Mechanismus). Das bedeutet, die Ermittlung einer
Klasse in einer Vertragsperiode via domain_class(class_name), wird mit einem `NameError` fehlschlagen, wenn die Klasse in
diesem Vertragsperioden-Namespace nicht existiert.

**Sanity-Checks:**
Das gesamte Repo hitobito_insieme wurde mit `grep -Rn "domain_class(" .` auf die Nutzung der domain_class Methode aus dem Dispatcher geprüft.
Die Methode wurde noch in folgenden Dateien verwendet:
- `app/models/event/course_record.rb:114: .domain_class("Event::CourseRecord::Calculation")`,
- `app/models/time_record.rb:84: .domain_class("TimeRecord::Calculation")` und
- `spec/domain/featureperioden/dispatcher_spec.rb:21: expect(subject.domain_class("TimeRecord::Table")).to be Fp2020::TimeRecord::Table`
Die Verwendung in dispatcher_spec.rb ist unproblematisch, in den beiden anderen Dateien fürht sie aber für die Jahre
2024 und nachfolgende zu einem `NameError` bei der Generierung von Kursstatistik Exporten und bei Zeiterfassungs-Berechnungen.
Deshalb wurde die domain_class Methode in den beiden betreffenden Models durch die fp_class Methode aus domain.rb ersetzt, welche
über die Fallback-Mechanik verfügt. Dadurch wird für 2024 und nachfolgende Jahre jetzt korrekt die Implementation aus der vorherigen VP
(`fp2022`) verwendet.

#### `domain_classes` Methode in dispatcher.rb (tolerante Enumeration)
`Featureperioden::Dispatcher.domain_classes` verhält sich jetzt tolerant.
Nicht existierende Klassen in einer VP werden übersprungen und als "FP skip ... not found" geloggt, statt
einen `NameError` auszulösen.

Die Methode `domain_classes(class_name)` von dispatcher.rb wird aktuell ausschliesslich in
`lib/hitobito_insieme/wagon.rb, 98` genutzt. Sie wird dort zur Boottime aufgerufen, um den tabellarischen Export-Klassen
die zugehöirgen Style-Klassen zuzuordnen und dieses Paar jeweils pro Vertragsperiode in einer Registry zu speichern:
- `"Export::Tabular::CostAccounting::List"` -> `"Export::Xlsx::CostAccounting::Style"` (Excel-Export Kostenrechnung)
- `"Export::Tabular::Events::AggregateCourse::DetailList"` -> `"Export::Xlsx::Events::AggregateCourse::Style"` (Excel-Export Sammelkurse)
- `"Export::Tabular::Events::AggregateCourse::ShortList"` -> `"Export::Xlsx::Events::AggregateCourse::Style"` (Excel-Export Sammelkurse)

Mit Einführung des neuen Fallback-Ansatzes werden Domainklassen jedoch nicht mehr vollständig in jede neue
VP kopiert. Das bedeutet:
- Bei der Enumeration über alle Vertragsperioden fehlen Klassen in neueren VPs, solange dort keine Overrides angelegt wurden.
- Mit der toleranten Implementierung von `domain_classes` werden fehlende Klassen neu übersprungen und per Logmeldung (FP skip: … not found) dokumentiert.
- Das ist erwartetes Verhalten und kein Fehler:  
  - **Kostenrechnung (CostAccounting):** die `::List`-Klassen werden hier direkt im `CostAccountingController` via `fp_class(class_name)` aufgerufen.
  Dadurch greift automatisch der Fallback-Mechanismus: existiert in der neuen VP noch keine Klasse, wird die letzte verfügbare Implementierung (z. B. aus Fp2022) genutzt.  
  - **Sammelkurse (AggregateCourse):** diese Exporte haben keinen eigenen Controller im Wagon, sondern laufen über die Boot-Time-Registrierung im `wagon.rb`.
  Dort wird beim Starten die jeweils letzte verfügbare Implementierung in die Registry eingetragen und später von `Export::Xlsx::Generator` genutzt.  
- Solange in einer neuen VP keine Overrides existieren, erscheinen also nur Logmeldungen (“skip … not found”), die Exporte selbst funktionieren aber weiterhin korrekt.  
- **Zukunft:** falls die Boot-Time-Registrierung zu laut oder unflexibel wird, könnte man die Zuweisung von Styles statt in `wagon.rb` auch lazy (zur Laufzeit) lösen,
z. B. direkt in den Controllern oder über einen Hook im `Generator`. Damit würde die Registry nur noch mit tatsächlich verwendeten Klassen befüllt.

#### Policy-Infrastruktur
Ab VP2024 gibt es zusätzlich eine Policy-Infrastruktur, um granulare Änderungen innerhalb einer VP umzusetzen, ohne jedes Mal eine neue FP-Struktur aufmachen zu müssen.
**Motivation:**
- Vertragsperioden laufen normalerweise 4 Jahre, aber innerhalb dieser Zeit können sich Regeln (z.B. BSV-Vorgaben) ändern.
- Policies kapseln diese kleineren Änderungen versionssicher, vermeiden doppelten Code und erhalten gleichzeitig die Reproduzierbarkeit pro Jahr.

**Aufbau:**
- `app/domain/policy_registry.rb`: Wählt für ein Jahr die richtige Policy-Klasse aus.
- `app/domain/policies/fsio2428/v10.rb`: Basis-Policy (z.B. für 2024).
- `app/domain/policies/fsio2428/v11.rb`: Geänderte Policy (z. B. für 2025+).
- Policy-Klassen sind einfach: sie liefern ein Label (`.label`) und definieren Methoden für spezifische Regeln, z.B.
`include_grundlagen_hours_for?(fachkonzept)`.

**Verwendung:**
- Eine VP-Klasse (z.B. `Fp2024::Export::Tabular::CourseReporting::ClientStatistics`) ruft `PolicyRegistry.for(year: year)` auf.
- Die zurückgegebenen Policy entscheidet dann, ob eine Berechnung wie bisher läuft oder angepasst wird.
- Beispiel: V10 (2024) addiert Grundlagenstunden für alle Kurstypen, V11 (2025+) nur noch für Treffpunkte.

#### Zusammenspiel von Fallback, Subclassing und Policies

Seit VP2024 basiert die Entwicklung auf drei ineinandergreifenden Mechanismen: **Fallback**, 
**Subclassing** und **Policies**. Diese Aufteilung ist bewusst gewählt.

1. **Ausrichtung auf BSV-Vertragsperioden**  
   - Jeder neue FP-Namespace entspricht einem neuen Vertragszyklus (z. B. `Fp2024` für BSV-Vertrag 2024–2028).  
   - Innerhalb dieses Zeitraums werden Änderungen im entsprechenden FP gebündelt, bis die nächste VP beginnt.

2. **Subclassing für Änderungen in der aktuellen VP (groß **oder** klein)**  
   - Neue oder geänderte Funktionalität wird in der **aktuellen VP** als Subclass der letzten relevanten Implementierung angelegt.  
   - Das gilt sowohl für **strukturelle Änderungen** (z. B. andere Spalten/Layouts) **als auch** für **kleine, VP-lokale Anpassungen**, bei denen wir die alten Namespaces nicht mit neuem Policy-Wiring anfassen wollen.  
   - Beispiel:  
     ```ruby
     class Fp2024::Export::Tabular::CourseReporting::ClientStatistics <
       Fp2022::Export::Tabular::CourseReporting::ClientStatistics
       def initialize(year, policy: Reporting::PolicyRegistry.for(year: year))
         super
         @policy = policy
       end

       # überschreibt nur das, was ab 2024/2025 in dieser VP gelten soll
     end
     ```
   - **Vorteile**: ältere Implementierungen (`Fp2022`, `Fp2020` …) bleiben unverändert; Änderungen sind eindeutig der aktuellen VP zugeordnet.

3. **Policies für Jahr-zu-Jahr-Anpassungen innerhalb einer VP**  
   - Kleinere Regeln, die sich im laufenden Zyklus ändern (z. B. ab 2025: Grundlagen-Stunden in Kursen ausschließen, in Treffpunkten beibehalten), werden als **Policy-Versionen** modelliert (`fsio2428 v1.0`, `v1.1`, …).  
   - Die Policy wird in der VP-Subclass injiziert und entscheidet pro **Kalenderjahr**, welche Variante gilt.  
   - **Ergebnis**: feingranulare Änderungen ohne neue FP und gleichzeitig **Reproduzierbarkeit pro Jahr**.

4. **Fallback für unveränderte Funktionalität**  
   - `fp_class("...")` sucht zuerst in der aktuellen VP und fällt dann **rückwärts** in ältere VPs zurück.  
   - So überschreiben wir nur Klassen, die sich wirklich ändern; Vollkopien entfallen.

**Entscheidungsleitfaden (Kurzfassung)**  
- **Nur alte Logik wiederverwenden?** → Nichts tun, Fallback reicht.  
- **Kleine VP-lokale Änderung (Policy-Wiring, punktuelle Methode):** → **Subclass in aktueller VP**, Policy injizieren, nur benötigte Methoden überschreiben.  
- **Große/strukturelle Änderung:** → **Subclass in aktueller VP** (oder Neuaufbau), alte VPs unangetastet lassen.  
- **Kleiner Jahreswechsel innerhalb VP (2024 vs. 2025):** → **Policy-Version** anpassen; Code bleibt in der VP-Subclass.

**Zusammenfassung:**  
- **Neue VP = neuer Namespace.**  
- **Änderungen (groß **oder** klein) in der aktuellen VP = Subclass dort**, damit ältere VPs sauber bleiben.  
- **Jahresweise Regeln = Policy-Versionen** innerhalb der VP.  
- **Unverändertes = Fallback** aus älteren VPs.

#### Vorteile dieser Architektur

Diese Architektur sorgt dafür, dass

- die Codebasis klar an die 4-jährigen Vertragszyklen des BSV gekoppelt bleibt,  
- Änderungen pro VP im Verzeichnisbaum sichtbar und nachvollziehbar sind (deltas statt Full-Copy),  
- kleinere Anpassungen innerhalb einer VP über **Policies** versionssicher umgesetzt werden können, ohne eine neue VP einführen zu müssen,  
- frühere VPs unverändert und reproduzierbar bleiben, während neue Anpassungen sauber im Namespace der aktuellen VP gekapselt sind,  
- Code-Duplikation stark reduziert wird,  
- und die Wartbarkeit sowie Transparenz insgesamt steigen (klare Trennung zwischen großen VP-Wechseln und kleinen Policy-Änderungen).

### i18n-Scope

Es gibt einen Viewhelper `fp_i18n_scope`, der Übersetzungen aus dem Scope `fp2020.#{controller_name}`
holt. Da diese Übersetzungen primär aus geänderten Views kommen, sind diese in `views.de.yml` (und
potentiell anderen Sprachen) eingefügt.

### Formularhelper

Der `StandardFormBuilder` wurde erweitert, um Labels angepasst übersetzt zu bekommen. Um
existierenden View-Code nicht unnötig anpassen zu müssen, wurde bisher nur eine neue Methode
hinzugefügt:

- `labeled_fp_input_field`

Es wird nur das Label mittels dem oben beschriebenen `fp_i18n_scope` überschrieben, andere Optionen
werden weitergereicht.

### RSpec

Die Helpermethode `fp_class` ist in allen specs verfügbar. Es wird erwartet, dass ein `let(:year)`
das jeweilige Jahr zurückgibt. Damit sollte mit relativ wenig Anpassungen existierender Code
weiterhin getestet werden können. Der Helper sollte nur in domain-specs notwendig sein.

## Hinweise in der Anwendung

- **Views**
  - In Controllern `include Featureperioden::Views` verwenden.
  - Neue oder angepasste Views in `app/views/fpYYYY` ablegen, um bestehende Views gezielt zu überschreiben.
  - Es wird immer nur ein VP-Verzeichnis im View-Path berücksichtigt.

- **Domain**
  - Neue oder geänderte Domainklassen immer in der **aktuellen VP** anlegen (z. B. `fp2024/`).
  - Unveränderte Funktionalität wird automatisch per **Fallback** aus älteren VPs übernommen.
  - Falls shared code über alle VPs auf eine neue Klasse zugreift, die in älteren VPs nicht existiert:
    - entweder den Aufruf per Jahr/Policy guarden, oder  
    - in älteren VPs eine **Stub-Klasse** (No-Op) definieren, um `NameError` zu vermeiden.
  - Für FP-spezifische Klassenauflösung: `include Featureperioden::Domain` und `fp_class('TimeRecord')` nutzen.  
    Beispiel:  
    ```ruby
    # statt direkt:
    TimeRecord.new(args)
    # korrekt:
    fp_class('TimeRecord').new(args)
    ```

- **Models**
  - Anzupassenden Code in eine Domainklasse verschieben (siehe „Domain“).

- **Controller**
  - Anzupassenden Code in eine Domainklasse verschieben (siehe „Domain“).

- **Specs**
  - Neue Specs, die speziell für eine VP sind, in `spec/fpYYYY/` anlegen.
  - Für Jahr-übergreifende Tests `let(:year)` setzen und `fp_class` verwenden.

## Probleme/Ausblick

### Featureperioden::Views

Aktuell ist `Featureperioden::Views` noch nicht im ApplicationController inkludiert, weil es auf
dem Vorhandensein einer `year`-Methode basiert, welche jedoch nicht überall vorhanden ist. Aktuell
nehmen wir dieses explizite `include` als Dokumentation hin, dass der viewpath angepasst wird.

### Formhelper

Es ist wahrscheinlich, dass noch weitere Methoden hinzukommen. Aktuell war nur eine Methode
notwendig. Es ist jedoch die Basis für weitere Methoden gelegt, die idealerweise auch nur das Label
anpassen müssen.

### shared_context 'featureperioden'

Es ist etwas unsauber, dass der "Shared Context" in allen Specs vorhanden ist. Besser wäre es
vielleicht, wenn diese nur den domain-specs inkludiert wird.

### Disziplin an Call-Sites
Ein Risiko ist die Verwendung von **harten Klassenreferenzen** (`Fp2022::…`) in gemeinsam genutztem Code.  
Damit wird der Fallback/Policy-Mechanismus umgangen und künftige Änderungen (z. B. in `Fp2024`) greifen ggf. nicht.  

**Ausblick / Maßnahmen:**
- Änderungen oder neue Funktionen in einer VP: immer `fp_class("…")` statt direkter Referenzen.  
- Falls eine Klasse nur ab einem Jahr existiert: Call guarden oder Stub/NullObject in älteren VPs.  
- Migration erfolgt **inkrementell** („on touch“), alte Pfade bleiben unangetastet.  
- Optional: kleine Guardrails in Reviews/CI, um neue harte Referenzen zu verhindern.

### Subclass-Chains & Architektur
- **Zu tiefe Vererbungsketten** (z. B. `Fp2029::X < Fp2024::X < Fp2022::X`) erschweren Verständnis und Debugging.  
  **Maßnahmen:** 
  - Bei Bedarf **flachziehen** (statt Subclass: Delegation/Wrapper oder Modul-Overrides via `prepend`).
  - Reusable Deltas in **kleine Module** extrahieren (z. B. `Fp2024::Overrides::...`) und in neuen FPs gezielt einbinden.
  - Pro Klasse dokumentieren, **von welcher Basis** geerbt/delegiert wird (kurzer Header-Kommentar).

### Fallback & Performance / Sichtbarkeit
- Fallback reduziert Kopien, erschwert aber das **Auffinden der „effektiven“ Implementierung**.
  **Maßnahmen:** 
  - „Override-Index“ pflegen (`docs/fp_overrides.md`): Liste aller Klassen, die in der aktuellen VP überschrieben sind, inkl. Basisklasse.
  - Optional: Rake-Task, der pro Klasse den **ersten Treffer** im Fallback-Pfad ausgibt (Dev-Hilfsmittel).

### Policy-Governance
- Risiko von **Policy-Sprawl** (viele kleine Versionen, unklare Zuständigkeit).
  **Maßnahmen:** 
  - **Benennungs-/Versionierungs-Konvention** festlegen (z. B. `FSIO-2024 v1.0`, `v1.1` für Jahresschnitte; `v2.0` bei Strukturwechsel).
  - **Registry** mit **Cutover-Datum** dokumentieren (Kommentar + Changelog). 
  - Jede Policy mit **„Effective as of“** versehen; Export stempelt **Profil + Version** in die Datei (Audit).