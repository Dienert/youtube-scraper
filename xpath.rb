require 'nokogiri'

file = "Barbixas - YouTube.html"
doc = Nokogiri::HTML(File.open(file, "r:UTF-8", &:read))

doc.xpath("").each do |titulo|
  puts titulo
end














































"//h3[@class='yt-lockup-title ']/a/text()"
