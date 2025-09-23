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

Seit `Fp2024` genügt es, eine leere Hülle für die neue VP anzulegen:

- `app/domain/fp2024.rb` mit `module Fp2024; end`
- optional ein leeres Verzeichnis `app/domain/fp2024/` (z.B. mit `export/`, `cost_accounting/`)
- Dann erweitert man den Dispatcher selbst (`app/domain/vertragsperioden/dispatcher.rb`), um die neue Vertragsperiode
bestimmen zu können (Methode `determine`). Ab dort dann normale Entwicklung in der neuen Vertragsperiode.

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
- **Neue Klasse ab einer VP**
  Direkt in `fp2024/` anlegen. Ältere VPs sehen diese Klasse nicht.

#### Forward-Limitierung
Da keine Vorwärts-Suche exisitiert, schlagen Zugriffe auf neue Klassen in älteren VPs mit `NameError` fehl.
Falls **shared code** über alle VPs versucht, auf neue Klasen zuzugreifen, gibt es zwei Lösungen:
- Guard im Code (z.B. durch Jahr-Check), oder
- Back-Copying von neuen Klassen als Stub-Klasse in ältere VPs.
Diese Stub-Klassen tun nichts, ausser die neue Klasse in alten VPs zu definieren, um den `NameError` zu vermeiden.

#### Enumeration
`Featureperioden::Dispatcher.domain_classes` verhält sich jetzt tolerant.
Nicht existierende Klassen in einer VP werden übersprungen und als "FP skip ... not found" geloggt, statt
einen `NameError` auszulösen.

#### Ein Wort zur domain_class Methode in dispatcher.rb
Diese Methode nutzt immer noch eine strikte Klassen-Ermittlung (kein Fallback-Mechanismus). Das bedeutet, die Ermittlung einer
Klasse in einer Vertragsperiode via domain_class(class_name), wird mit einem `NameError` fehlschlagen, wenn die Klasse in
diesem Vertragsperioden-Namespace (noch) nicht existiert.

{Beispiel anhand Fp2024}: ...

**Sanity-Checks:**
Das gesamte Repo hitobito_insieme wurde mit `grep -Rn "domain_class(" .` auf die Nutzung der domain_class Methode aus dem Dispatcher geprüft.
Die Methode wurde noch in folgenden Dateien verwendet:
- `app/models/event/course_record.rb:114: .domain_class("Event::CourseRecord::Calculation")`,
- `app/models/time_record.rb:84: .domain_class("TimeRecord::Calculation")` und
- `spec/domain/featureperioden/dispatcher_spec.rb:21: expect(subject.domain_class("TimeRecord::Table")).to be Fp2020::TimeRecord::Table`
Die Verwendung in dispatcher_spec.rb ist unproblematisch, in den beiden anderen Dateien fürht sie aber für die Jahre
2024 und nachfolgende zu einem `NameError` bei der Generierung von Kursstatistik Exporten und bei Zeiterfassungs-Berechnungen.
Deshalb wurde die domain_class Methode in den beiden betreffenden Models durch die fp_class Methode aus domain.rb ersetzt, welche
über die Fallback-Mechanik verfügt. Dadurch wird für 2024 und nachfolgende Jahre jetzt korrekt die Implementation aus der Vertrgas-
periode 2022 verwendet.

#### Vorteile dieser Implementierung
- Weniger Code-Duplikation
- Änderungen pro VP sind im Verzeichnisbaum klar sichtbar (deltas statt Full-Copy)
- (hoffentlich) erhöhte Wartbarkeit und Transparenz
- Grunlage für eine saubere Angleichung der VP/fp-Struktur an die BSV-Vertragsperioden (4-Jahreszyklen)
- Innerhalb einer VP können kleinere Änderungen künftig über Policies abgebildet werden, ohne gleich
eine neue VP einführen zu müssen

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

- views:
  - `*Controller` -> `include Featureperioden::Views`
  - neue Views in `app/views/fp2020` anlegen und so existierende Views überschreiben
- domain:
  - Neue oder geänderte Domainklassen nur in der aktuellen FP ablegen.
  - Unveränderte Funktionalität wird per Fallback aus älteren FPs übernommen.
  - `include Featureperioden::Domain` verwenden und mit `fp_class('TimeRecord')` aufrufen.
  - z.B. `TimeRecord.new(args)` -> `fp_class('TimeRecord').new(args)`
- models:
  - anzupassenden Code in eine Domain-Klasse verschieben
  - Siehe "domain" :-)
- controller:
  - anzupassenden Code in eine Domain-Klasse verschieben
  - Siehe "domain" :-)
- specs:
  - neue Specs, die speziell für eine VP sind, werden in `spec/fp2020/` angelegt.

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

### neue Featureperioden

Der bestehende rake-task `rake fp:new[YEAR]` erzeugt aktuell noch eine neue VP durch
Kopieren der Dateien der bisherigen FP und Ersetzten der bisherigen Jahreszahl mit der neuen.
Mit dem neuen Fallback-Mechanismus ist das nicht mehr notwendig.
Der Task sollte künftig nur noch:
- `app/domain/fpYYYY.rb mit leerem Modul anlegen,
- ein leeres Verzeichnis `app/domain/fpYYYY/` erzeugen.

Diese Anpassung des Rake-Tasks ist noch nicht umgesetzt. Bis dahin verhält er sich weiterhin
nach der alten Logik (Full-Copy).

**Vor September 2025:**
Es existiert ein rake-task (`lib/tasks/fp.rake`), der dabei hilft, eine neue Vertragsperiode
anzulegen (im Kern eine Mischung aus `cp` und `find | sed -i`):

    `rake fp:new[YEAR]`

YEAR ist dabei das "neue Anfangsjahr" der Vertragsperiode und damit
gleichzeitig das namensgebende Jahr. Es werden fast alle Dateien für die
bisherige FP kopiert und das bisherige Jahr mit dem neuen ersetzt.

Damit ist ein Startpunkt vorhanden, von dem aus die neue Vertragsperiode
implementiert werden kann.

### Angleichung FP-Namespaces und BSV-Vertragsperioden
- In Zukunft ist eine klare Angleichung der Entwicklungshistorie von FP-Namespaces und den 
BSV-Vertragsperioden (business cycles) vorgesehen.
- Kleinere Anpassungen innerhalb einer VP können über **Policies** ermöglicht werden, ohne eine komplett
neue VP anlegen zu müssen.
