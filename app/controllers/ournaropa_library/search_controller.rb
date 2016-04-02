require_dependency "ournaropa_library/application_controller"

module OurnaropaLibrary
  class SearchController < ApplicationController
    
    require "uri"

    # GET /search/QUERY
    def show
      
      @query = params[:query]
      
      @search_naropa  = params[:naropa]
      @search_cu      = params[:cu]
      @search_bpl     = params[:bpl]
      
      render :show 
      # search CU
      
      # search BPL      
      
    end  
    
    
    # search Naropa
    def fetch_results
      
      @query = URI.encode params[:query]
      @school = params[:school]
      
      puts case @school
      when "naropa"
        @results = fetch_from_naropa @query
      when "cu"
        @results = fetch_from_cu @query
      when "bpl"
        @results = fetch_from_bpl @query
      end
        
      respond_to do |format|
       format.js { render :show_results }
      end
      
    end
  
  private
  
    # fetches from Naropa 
    def fetch_from_naropa query
      url = "http://howlcat.naropa.edu/cgi-bin/koha/opac-search.pl?q=#{query}&branch_group_limit="
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
        
      results = []
      
      # parse results
      if content.css(".bibliocol").present?
        content.css(".bibliocol").each do |result|

          results.push({
            :title => result.css(".title").text,
            :author => result.css(".author").text,
            :availability => result.css(".available").blank? ? result.css(".unavailable").text : result.css(".available").text,
            :url => "http://howlcat.naropa.edu" + result.css(".title").attribute("href").value

            })

        end
      end
      
      return results
      
    end
    
    def fetch_from_bpl query
      url = "http://boulder.flatironslibrary.org/Union/Search?lookfor=#{query}"
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
        
      results = []
      
      # parse results
      content.css(".result").each do |result|
        
        availability = "<ul>"
        
        result.css(".row.related-manifestation").each do |manifestation|
          availability += "<li>" + manifestation.css(".manifestation-format > a:first-of-type").text + ": " + manifestation.css(".manifestation-format + div > .related-manifestation-shelf-status").text + " &mdash; " + manifestation.css(".manifestation-format + div > .smallText").text + "</li>"
        end
        
        availability += "</ul>"
        
        results.push({
          :title => result.css(".result-title").text,
          :author => result.css(".resultsList > .row .row:nth-of-type(2) .result-value").text,
          :availability => availability,
          :url => "http://boulder.flatironslibrary.org" + result.css(".result-title").attribute("href").value
          
          })
        
      end
      
      return results
      
    end
    
    # search CU library
    def fetch_from_cu query
      url = "http://encore.colorado.edu/iii/encore/search/C__S" + query + "__Orightresult__U?lang=eng&suite=cobalt"
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
        
      results = []
          
      # parse result
      if content.css("#resultsAnyComponent").present?
        content.css(".searchResult").each do |result|

          if result.css(".title").present?
         
            results.push({
              :title => result.css(".title:first-of-type").text,
              :author => result.css(".dpBibAuthor").text,
              :availability => result.css(".availabilitySummaryArea").text,
              :url => "http://encore.colorado.edu/" + result.css(".title a").attribute("href").value

              })
          end
            
        end
      end

      return results
      
    end
    
    
    # fetches content from a given url
    def fetch_from_url url
      require "net/http"

      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      request['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36 OPR/36.0.2130.46'
      
      response = http.request(request)
        
      return response.body             # => The body (HTML, XML, blob, whatever)
    end

  end
  
end
