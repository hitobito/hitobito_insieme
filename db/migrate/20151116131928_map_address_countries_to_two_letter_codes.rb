# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class MapAddressCountriesToTwoLetterCodes < ActiveRecord::Migration[4.2]

  def up
    return if test_data?

    Person::ADDRESS_TYPES.each do |type|
      say_with_time("updating people #{type}_country") do
        CountryMapper.new(type).update_and_persist
      end
    end
  end

  def down
  end

  private

  def test_data?
    Group.pluck(:type).any? { |type| type == 'Group::BottomLayer' }
  end

  class CountryMapper
    attr_reader :map, :changes, :failed, :log
    attr_reader :type, :file

    LANGUAGES = %w(de fr it en)

    def initialize(type)
      @map, @failed = {}, []
      @changes = Hash.new { |k, v| k[v] = [] }
      @log = Hash.new { |k, v| k[v] = Set.new }
      @type = type

      @file = Rails.root.join("./log/person_country_migration.log")

      define(:BO, "Bolivien")
      define(:CH, ["Suisss", "swiss", "Suisse/Schweiz", "Schwiiz", "Schwiz", "Schwiez", "Scheiz",
                   "Scnweiz", "Scweiz", "Schnweiz", "Schweizz", "Schweit", "Sxhweiz", "Scnweiz",
                   "Schwei", "Schweitz" "Schweizer", "Schweiu", "Schweo",
                   "Schweiz (CH)", "Schweizer", "Schweitz",
                   "Bern", "Berikon", "Lucerne", "Hettlingen", "St.Gallen", "Solothurn", "Luzern",
                   "CH - Schweiz", "Schweiz CH", "Schweiz - CH", "CH (Schweiz)", "CH/IT",
                   "Freiburg", "ZH", "Aargau", "Baselland" ])
      define(:IT, "I - Italy")
      define(:LI, "Fürstentumlichtenstein")
      define(:DE, "Deutschalnd")
      define(:ES, "Espagna")
      define(:FR, "F")
      define(:PT, "Portugaise")
      define(:SG, "Republik Singapur")
      define(:TH, "TH - Thailand")
      define(:US, ["Amerika", "USA"])

      define_accepted_translations
    end

    def update_and_persist
      update
      persist
    end

    def update
      Person.where("#{type}_country IS NOT null").find_each do |model|
        value = model.send("#{type}_country").strip.downcase

        if map[value]
          model.send("#{type}_country=", map[value])
          changes[model.send("#{type}_country")] << model.id
          log[:mapped] << model.changes["#{type}_country"] if model.changed?
        else
          failed << model.id
          log[:failed] << model.send("#{type}_country")
        end
      end

      log
    end

    def persist
      changes.each do |country, ids|
        Person.where(id: ids.to_a).update_all("#{type}_country" => country)
      end

      Person.where(id: failed).update_all("#{type}_country" => nil)

      File.write(file, log)
      changes.values.flatten.size
    end

    private

    def define(key, args)
      Array(args).each { |value| map[value.downcase] = key.to_s }
    end

    def define_accepted_translations
      map.merge!(keyed_translations)
    end

    # returns country code map with translations, e.g. 'CH' => %w(Schweiz Suisse Switzerland)
    def keyed_translations
      hash = {}
      LANGUAGES.map do |lang|
        Countries.labels(lang).map do |key, value|
          hash[key.downcase] = key
          if value.present?
            hash[value.downcase] = key
            hash[ActiveSupport::Inflector.transliterate(value).downcase] = key
          end
        end
      end
      hash
    end
  end

end
