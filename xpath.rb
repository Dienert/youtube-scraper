require 'nokogiri'

file = "Barbixas - YouTube.html"
doc = Nokogiri::HTML(File.open(file, "r:UTF-8", &:read))

doc.xpath("//h3[@class='yt-lockup-title ']/a/text()").each do |titulo|
  puts titulo
end

