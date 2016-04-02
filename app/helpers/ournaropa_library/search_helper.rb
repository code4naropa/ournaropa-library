module OurnaropaLibrary
  module SearchHelper
    
    def full_school_name abbreviation
      puts case abbreviation
        when "naropa"
        return "Naropa University Libraries"
        when "cu"
        return "University of Colorado Boulder Libraries"
        when "bpl"
        return "Boulder Public Library"
      end
    end
    
    def num_results_per_source
      return 10
    end
    
  end
end
