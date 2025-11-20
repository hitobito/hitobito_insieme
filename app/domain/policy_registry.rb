class PolicyRegistry
  def self.for(year:)
    case year.to_i
    when 2024
    # when 2025..Float::INFINITY
    # Policies::Fsio2428::V11.new
    end
    Policies::Fsio2428::V10.new
  end
end
