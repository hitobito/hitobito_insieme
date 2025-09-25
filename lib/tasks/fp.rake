# frozen_string_literal: true

#  Copyright (c) 2022, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "fileutils"

# rubocop:disable Metrics/BlockLength
namespace :fp do
  desc "Create a new Featureperiode skeleton (domain = shell only, views still copied)"
  task :new, [:year] => [:environment] do |_, args|
    args.with_defaults(year: Date.current.year)
    year = args[:year].to_i

    known_years = Featureperioden::Dispatcher::KNOWN_BASE_YEARS
    last_year = known_years.last

    abort "#{year} is already known" if known_years.include?(year)
    puts "#{last_year} -> #{year}"

    wagon_root = Wagons.find("insieme").root
    domain_root = wagon_root.join("app/domain")
    views_root = wagon_root.join("app/views")
    spec_root = wagon_root.join("spec")

    # --- 1) Views (unchanged behavior) ---------------------------------------
    # keep copying fp-specific views so explicit overrides are available
    from_views = views_root.join("fp#{last_year}")
    to_views = views_root.join("fp#{year}")

    if from_views.exist?
      if to_views.exist?
        puts "views/fp#{year} already exists, skipping copy"
      else
        FileUtils.cp_r(from_views, to_views)
        puts "copied views: #{from_views} -> #{to_views}"
      end
    else
      puts "no fp#{last_year} views to copy (#{from_views} missing)"
    end

    # --- 2) Domain (NEW: shell only, no copy) --------------------------------
    fp_module_file = domain_root.join("fp#{year}.rb")
    fp_folder = domain_root.join("fp#{year}")

    # create module file if missing
    if fp_module_file.exist?
      puts "exists:  #{fp_module_file}"
    else
      File.write(fp_module_file, "module Fp#{year}; end\n")
      puts "created: #{fp_module_file}"
    end

    # create empty fp folder (for deltas / overrides)
    if fp_folder.exist?
      puts "exists:  #{fp_folder}/"
    else
      FileUtils.mkdir_p(fp_folder)
      FileUtils.touch(fp_folder.join(".keep"))
      puts "created: #{fp_folder}/"
    end

    # --- 3) Spec skeletons (no copies; just empty dirs) -------------------------
    %w[domain models].each do |subdir|
      dst = spec_root.join(subdir, "fp#{year}")
      if dst.exist?
        puts "exists:  #{dst}/"
      else
        FileUtils.mkdir_p(dst)
        FileUtils.touch(dst.join(".keep"))
        puts "created: #{dst}/"
      end
    end
    puts "NOTE: No spec files copied. Add specs only where you add/override domain classes in fp#{year}."

    # --- 4) Update dispatcher KNOWN_BASE_YEARS --------------------------------
    dispatcher_path = domain_root.join("featureperioden/dispatcher.rb")
    new_supported = (known_years + [year]).uniq.sort
    content = File.read(dispatcher_path)
    content.sub!(/KNOWN_BASE_YEARS = \[.*\](?:\.freeze)?/,
      "KNOWN_BASE_YEARS = [#{new_supported.join(", ")}].freeze")

    File.write(dispatcher_path, content)
    puts "updated KNOWN_BASE_YEARS in #{dispatcher_path} -> #{new_supported.inspect}"

    # --- 5) TODOs -------------------------------------------------------------
    puts "TODOs:"
    puts "- [ ] Adapt spec/domain/featureperioden/dispatcher_spec.rb to cover #{year}."
    puts "- [ ] Add and commit the additions NOW to keep commits small and focussed."

    puts "- [ ] Add CHANGELOG entry: 'Vertragsperiode #{year} hinzugefügt (Domain: Fallback, Views: Kopie)'."
    puts "- [ ] Add and commit the additions NOW to keep commits small and focussed."

    puts "- [ ] Run specs and fix failing ones"
    puts "- [ ] Add and commit the additions NOW to keep commits small and focussed."

    puts "- [ ] Create only the domain classes you actually change in app/domain/fp#{year}/ (override via subclass)."
    puts "- [ ] Add and commit the additions NOW to keep commits small and focussed."

    puts "- [ ] Check locales for new/changed View-keys in app/views/fp#{year}/*."
    puts "- [ ] Add and commit the additions NOW to keep commits small and focussed."

    puts "- [ ] Inform client about the need to change translations"
  end
end
# rubocop:enable Metrics/BlockLength
