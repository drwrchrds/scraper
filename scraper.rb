require 'nokogiri'
require 'open-uri'
require 'debugger'

# PAGE_URL = "http://ruby.bastardsbook.com/files/hello-webpage.html"
# PAGE_URL = "http://ruby.bastardsbook.com/files/hello-webpage.html"
TASK_URL = "http://task.wmflabs.org/wiki/Averza"
PAGES_URL = "http://task.wmflabs.org/wiki/Special:AllPages"

page_index = Nokogiri::HTML(open(PAGES_URL))

all_index_urls = page_index.css('.mw-allpages-alphaindexline a')


# collect all page urls
# all_urls = []

broken_pages = []
all_index_urls.each do |url|

  puts "parsing " + url["href"]
  page = Nokogiri::HTML(open("http://task.wmflabs.org" + url["href"]))
  all_page_urls = page.css('.mw-allpages-table-chunk a')

  all_page_urls.each do |sub_url|
    begin
      puts "parsing sub_page " + sub_url["href"]
    
      sub_page = Nokogiri::HTML(open("http://task.wmflabs.org" + sub_url["href"]))
      nav_links = sub_page.css('a') - sub_page.css('#content a')
      
      qqx_sub_page = Nokogiri::HTML(open("http://task.wmflabs.org" + sub_url["href"] + "?uselang=qqx"))
      qqx_nav_links = qqx_sub_page.css('a') - sub_page.css('#content a')

      # get link text
      link_text = nav_links.map do |link|
        link.children.first.content if !link.children.empty?
      end
      
      # get identifier text
      qqx_link_text = qqx_nav_links.map do |link|
        link.children.first.content[1..-2] if !link.children.empty?
      end


      link_text.each_with_index do |link, idx|
        qqx_link = qqx_link_text[idx]
        
        # puts "#{link}, #{qqx_link}"
        # see if link matches the identifier text
        if !link.nil? && ( link.match(qqx_link) || link.match('&') )
          broken_pages << sub_page.title 
          puts 'found one ' + sub_page.title
        end
      end
    rescue => e
      puts e.message
    end
  end
end

puts "broken pages are #{broken_pages}"





# do this for each webpage
# broken_pages = []
# page = Nokogiri::HTML(open("http://task.wmflabs.org/wiki/Averza"))
# nav_links = page.css('#mw-panel a')
# 
# link_text = nav_links.map do |link|
#   link.children.first.content if !link.children.empty?
# end
# 
# if link_text.any?{|text| text.match(/&lt;/) if !text.nil? }
#   broken_pages << page.title 
#   puts 'found one ' + page.title
# end
# 
# 
# puts broken_pages