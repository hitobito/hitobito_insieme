module Export::Event
  class Filename
    attr_reader :group, :type, :year

    def initialize(group, type, year)
      @group = group
      @type  = type
      @year  = year
    end

    def to_s
      vid = group.vid.present? ? "_vid#{group.vid}" : ''
      bsv = group.bsv_number.present? ? "_bsv#{group.bsv_number}" : ''
      "#{filename_prefix}#{vid}#{bsv}_#{group_name}_#{year}"
    end

    private

    def filename_prefix
      type.to_s.demodulize.underscore.presence || 'simple'
    end

    def group_name
      group.name.parameterize
    end

  end
end
