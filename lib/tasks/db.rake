# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# rubocop:disable Metrics/BlockLength

# Original from: https://github.com/thams/db_fixtures_dump/
namespace :db do
  namespace :fixtures do
    desc 'Dumps some models into fixtures.'
    task dump: :environment do
      Rake::Task['fixtures:groups'].invoke

      puts '# Please copy this into the spec/fixtures/groups.yml yourself'
    end
  end

  namespace :import do
    desc <<~TEXT
      Import summed values for capital substrates for earlier years

      This import expects a CSV-File (named previous_capital_substrates.csv by default)
      with two fields:
        - group_id (numeric id of the group)
        - sum      (sum of previous Vertragsperioden, float-parseable)
    TEXT
    task :previous_capital_substrates, [:year, :filename] => [:environment] do |_, args|
      args.with_defaults(filename: 'previous_capital_substrates.csv')
      abort 'this needs a year in which the capitalsubstrates are summed up' if args.year.nil?

      puts 'Importing summed values for capital substrates of previous years'
      puts "Reading from:   #{args.filename}"
      puts "Storing sum in: #{args.year}"

      cs_sum_csv = Pathname.new(args.filename)

      abort 'Import file not found' unless cs_sum_csv.exist?

      unless cs_sum_csv.each_line.first =~ /group_id.*sum/
        abort 'Import file is not in the expected format'
      end

      require 'csv'

      puts 'Importing data'
      errors = []
      CSV.parse(cs_sum_csv.read, headers: true).each do |row|
        cs = CapitalSubstrate.find_or_create_by(year: args.year, group_id: row['group_id'])
        cs.previous_substrate_sum = row['sum']
        if cs.save
          print '.'
        else
          print 'E'
          errors << [cs, row]
        end
      end
      puts
      puts 'Done.'

      if errors.any?
        puts
        puts "There have been #{errors.size} Errors:"

        errors.each do |cs, row|
          puts cs.inspect, row.inspect
        end
        puts 'End of Errors.'
      end
    end

    desc 'Convert Group-Names to Group-IDs'
    task :convert, [:filename] => [:environment] do |_, args|
      args.with_defaults(filename: 'previous_capital_substrates.csv')

      puts 'Convert Group-Names to group-ids for capital substrates of previous years'
      puts "Reading from:   #{args.filename}"

      cs_sum_csv = Pathname.new(args.filename)

      abort 'Import file not found' unless cs_sum_csv.exist?

      require 'csv'

      puts 'Converting data'
      errors = []
      new_data = []
      CSV.parse(cs_sum_csv.read, headers: true).each do |row|
        name, sum = row.fields

        group =
          Group.without_deleted.find_by(full_name: name) ||
          Group.without_deleted.find_by(full_name: name.strip) ||
          Group.without_deleted.find_by(name: name) ||
          Group.without_deleted.find_by(name: name.strip)

        if group.present?
          new_data << [group.id, sum]
          print '.'
        else
          print 'E'
          errors << [row]
        end
      end

      puts
      puts 'Done.'

      if errors.any?
        puts
        puts "There have been #{errors.size} Errors:"

        errors.each do |row|
          puts row.inspect
        end
        puts 'End of Errors.'
        puts
      end

      CSV.open(
        "#{cs_sum_csv.dirname}/converted-#{cs_sum_csv.basename}", 'w',
        headers: %w(group_id sum),
        write_headers: true
      ) do |csv|
        new_data.each do |id, sum|
          csv << [id, sum]
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
