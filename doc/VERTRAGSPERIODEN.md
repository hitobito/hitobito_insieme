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

Die Hauptarbeit der Auswertungen wird von Domainklassen erledigt. Domainklassen, die Unterschiede
haben, werden in einen Namespace gekapselt, der der jeweiligen Vertragsperiode entspricht. Wenn eine
Domainklasse Unterschiede aufgrund der Vertragsperiode hat, muss man die existierende Klasse in die
bisherigen Featureperioden verschieben.

Um die Domainklasse einer Vertragsperiode zu laden, bietet der Dispatcher einen Helper, um einen
existierenden Klasse in jeweilgen Namespace zu suchen. Aufgrund der Konventionen, die in zeitwerk
eincodiert sind, ergibt sich, dass die Dateien in `app/domain/fp2020/` gespeichert werden.

Der Helper `fp_class` ist verfügbar, wenn man in die entsprechende Klasse das Modul
`Featureperioden::Domain` inkludiert. Die Methode `year` muss implemetiert sein, entweder explizit
oder implizit im Fall von `ActiveRecord`-Subklassen.

Der Helper gibt nur die Klasse im korrekten Namespace zurück, da die konkrete Verwendung nicht
vorhergesehen werden kann.

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
  - existierenden Code nach `app/domain/fp2015` und `app/domain/fp2020` kopieren
  - aufrufenden Code mit `fp_class`-Helper aufrufen:
  - `include Featureperioden::Domain`
  - z.B. `TimeRecord.new(args)` -> `fp_class('TimeRecord').new(args)`
- models:
  - anzupassenden Code in eine Domain-Klasse verschieben
  - Siehe "domain" :-)
- controller:
  - anzupassenden Code in eine Domain-Klasse verschieben
  - Siehe "domain" :-)
- specs:
  - neue Specs, die speziell für eine VP sind, werden in `spec/fp2020/` angelegt.

## Neue Featureperioden

Idealerweise kopiert man alle `fp*`-Verzeichnisse der vorherigen Vertragsperiode und passt das Jahr
in den neuen Dateien an. Dann erweitert man den Dispatcher selbst
(`app/domain/vertragsperioden/dispatcher.rb`), um die neue Vertragsperiode bestimmen zu können
(Methode `determine`). Ab dort dann normale Entwicklung in der neuen Vertragsperiode.

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

Es existiert ein rake-task, der dabei hilft, eine neue Vertragsperiode
anzulegen (im Kern eine Mischung aus `cp` und `find | sed -i`):

    `rake fp:new[YEAR]`

YEAR ist dabei das "neue Anfangsjahr" der Vertragsperiode und damit
gleichzeitig das namensgebende Jahr. Es werden fast alle Dateien für die
bisherige FP kopiert und das bisherige Jahr mit dem neuen ersetzt.

Damit ist ein Startpunkt vorhanden, von dem aus die neue Vertragsperiode
implementiert werden kann.

### neue Domainklassen

Aktuell müssen neue Domainklassen auch für alle vergangenen Featureperioden implementiert werden.
Die könnte man entweder durch eine intelligenteren Lookup machen (`determine` müsste ein Liste von
vorherigen oder nachfolgenden VPs haben) oder die notwendigen Dateien via script vereinfacht
kopieren/erstellen/anpassen können.
