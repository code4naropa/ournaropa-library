require_dependency "ournaropa_library/application_controller"

module OurnaropaLibrary
  class SearchController < ApplicationController
    
    require "uri"

    # GET /search/QUERY
    def show
      
      @query = params[:query]
      
      @search_naropa  = params[:naropa].present? ? params[:naropa] : false
      @search_cu      = params[:cu].present? ? params[:cu] : false
      @search_bpl     = params[:bpl].present? ? params[:bpl] : false
      
      
      # if all three are false, then the user must have forgotten to put in the search libraries --- we'll search all three
      if @search_naropa == false && @search_cu == false && @search_bpl == false
        @search_naropa = @search_cu = @search_bpl = true
      end
        
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
        @link_to_results = "http://howlcat.naropa.edu/cgi-bin/koha/opac-search.pl?q=#{@query}&branch_group_limit="
        @results = fetch_from_naropa @link_to_results
      when "cu"
        @link_to_results = "http://encore.colorado.edu/iii/encore/search/C__S#{@query}__Orightresult__U?lang=eng&suite=cobalt"
        @results = fetch_from_cu @link_to_results
      when "bpl"
        @link_to_results = "http://boulder.flatironslibrary.org/Union/Search?lookfor=#{@query}"
        @results = fetch_from_bpl @link_to_results
      end
        
      respond_to do |format|
       format.js { render :show_results }
      end
      
    end
  
  private
  
    # fetches from Naropa 
    def fetch_from_naropa url
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
      
      results = []
      @result_count = 0
      
      # parse results
      if content.css(".bibliocol").present?
        
        # GET NUMBER RESULTS
        @result_count = content.css("#numresults").text
        # cut away useless info
        @result_count = @result_count[0, @result_count.index(' results.')].strip
        # cut away currently showing
        @result_count = @result_count[@result_count.rindex(' ')+1, @result_count.length]
      
        # PARSE RESULTS
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
    
    def fetch_from_bpl url
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
        
      results = []
      @result_count = 0
      
      # PARSE RESULTS
      if content.css(".result").present?
        
        # GET NUMBER RESULTS
        @result_count = content.css(".result-head").text
        # cut away query time
        @result_count = @result_count[0, @result_count.index(' query')].strip
        # cut away currently showing
        @result_count = @result_count[@result_count.rindex(' ')+1, @result_count.length]
        
        
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
      end
      
      return results
      
    end
    
    # search CU library
    def fetch_from_cu url
      
      # fetch contents
      content = Nokogiri::HTML(fetch_from_url url)
            
      results = []
      @result_count = 0
          
      # parse result
      if content.css("#resultsAnyComponent").present?
        
        # GET NUMBER OF RESULTS
        @result_count = content.css("#searchResultsAnyComponent .noResultsHideMessage").text.strip
        # cut away currently showing
        @result_count = @result_count[@result_count.rindex(' ')+1, @result_count.length]

        # PARSE RESULTS
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
