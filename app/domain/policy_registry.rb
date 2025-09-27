class PolicyRegistry
    
  def self.for(year:)
    case year.to_i
    when 2024
      Policies::Fsio2428::V10.new
    when 2025..Float::INFINITY
      Policies::Fsio2428::V11.new
    else
      Policies::Fsio2428::V10.new
    end
  end
end