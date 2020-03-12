class ChangeCantonOtherToAnother < ActiveRecord::Migration[4.2]
  def change
    # transifex forbidds keys be called `other` unless they contain the plural form
    # of a corresponding `one` key.
    Person.where(canton: 'other').update_all(canton: 'another')
    Person.where(language: 'other').update_all(language: 'another')
    Group.where(canton: 'other').update_all(canton: 'another')

    rename_column :event_participation_canton_counts, :other, :another
    Event::ParticipationCantonCount.reset_column_information
  end
end
