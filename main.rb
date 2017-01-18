require 'mechanize'
require 'json'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = 1

a = Mechanize.new { |agent|
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko'
}


def get_videos page, video, output
  divs = page.xpath('.//div[contains(@class, "yt-lockup-video")]')

  divs.each do |div|
    duracao = div.xpath('.//span[@class="video-time"]/span/text()').to_s
    tempo = duracao.split(':')
    if tempo.length == 2
      duracao = tempo[0].rjust(2, "0")+":"+tempo[1]
    else
      duracao = tempo[0]+":"+tempo[1].rjust(2, "0")+":"+tempo[2]
    end
    imagem = div.xpath('.//span[@class="yt-thumb-clip"]/img/@src')
    div_content = div.xpath('.//div[contains(@class, "yt-lockup-content")]')
    titulo = div_content.xpath('.//a/text()')
    link = div_content.xpath('.//a/@href')
    metainfo = div_content.xpath('.//ul[@class="yt-lockup-meta-info"]')
    views = metainfo.xpath('./li[1]/text()')
    views = views.to_s.split("\s")[0]
    views = views.gsub(%r{,}, "")
    dias = metainfo.xpath('./li[2]/text()')
    video += 1
    saida = "#{video};#{titulo};#{duracao};#{views};#{dias};https://www.youtube.com#{link};#{imagem}"
    #puts saida
    output.puts saida
  end
  video
end

canal = ARGV[0]

canal = "portadosfundos" if canal.nil? || canal.empty?

output = File.open("#{canal}.csv", "w")

test_file = File.open("test.html", "w")

page = a.get("https://www.youtube.com/user/#{canal}/videos")

video = 0
video = get_videos page, video, output
pag = 1

link = page.xpath('.//button[contains(@class, "load-more-button")]/@data-uix-load-more-href')

loop do
  break if link.empty?
  pag += 1
  page = a.get("https://www.youtube.com"+link.to_s)
  #puts "\nPag: #{pag}\n"
  obj = JSON.parse(page.content.to_s)
  page = obj["content_html"]
  link = Nokogiri::HTML(obj["load_more_widget_html"]).xpath(
    './/button[contains(@class, "load-more-button")]/@data-uix-load-more-href')
  page = Nokogiri::HTML(page)
  video = get_videos page, video, output
end
#output = File.open("resultado.html", "w");output.puts page;
