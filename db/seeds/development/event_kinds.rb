# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

quali_kinds = QualificationKind.seed(:id,
 {id: 1,
  validity: 2}
)

QualificationKind::Translation.seed(:label,
 {qualification_kind_id: quali_kinds[0].id,
  locale: 'de',
  label: 'Experte'}
)

event_kinds = Event::Kind.seed(:id,
 {id: 1}
)

Event::Kind::Translation.seed(:short_name,
 {event_kind_id: event_kinds[0].id,
  locale: 'de',
  label: 'Expertenkurs',
  short_name: 'EK'}
)

Event::KindQualificationKind.seed(:id,
  {id: 1,
   event_kind_id: event_kinds[0].id,
   qualification_kind_id: quali_kinds[0].id,
   category: :qualification,
   role: :participant}
)
