require 'utils'
require 'json/pure'


module Rich
  module Rich
    include ::Utils, ::Kaixin
    RICH_URL = "/!richcity"

    def rich_main
      url = "#{BASE_URL}#{RICH_URL}/index.php?t=#{rand(100)}"
      page = http_get_data(url)
    end

    def games(doc=nil)
      doc = rich_main unless doc
      game_ids = []
      doc.links_with(:href => /gid/).each do |a|
        game_ids << a.href.split('=')[1]
      end
      game_ids
    end

    def game_main(game_id)
      url = "#{BASE_URL}#{RICH_URL}/index.php?gid=#{game_id}"
      doc = http_get_data(url)
    end

    def current_items(game_id)
      url = "#{BASE_URL}#{RICH_URL}/!api_usertool.php?rt=xml&gid=#{game_id}&rand=#{rand}&act=my"
      doc = http_get_data(url)
      items = doc.search('//item').to_a.map{|node| node.children.inject({}){|a,c| a[c.name] = c.text if c.class == Nokogiri::XML::Element; a}}
    end

    def users_in_game(game_id)
      users = []
      doc = game_main(game_id)
      doc.search('//div[@class="game_item"]/a[@class="sl2"]').each do |item|
        users << item['href'].split('=')[1]
      end
      users.delete(@user[:id].to_s)
      users
    end

    def users_info(game_id)
      info = Hash.new
      users = []
      doc = game_main(game_id)
      doc.search('//div[@class="game_item"]/a[@class="sl2"]').each do |item|
        users << item['href'].split('=')[1]
      end
      users.delete(@user[:id].to_s)
      users.each do |user_id|
        info.update(user_id => {
          'name' => doc.search("//div[@class=\"game_item\"]/a[@href=\"/home/?uid=#{user_id}\"]")[0].content,
          'cash' => doc.search("//span[@id=\"info_cash#{user_id}\"]")[0].content,
            'save' => doc.search("//span[@id=\"info_save#{user_id}\"]")[0].content,
            'lend' => doc.search("//span[@id=\"info_lend#{user_id}\"]")[0].content
        })
      end
      info
    end

    #计算需要多少张查税卡
    def check_num(total_money, num = 1)
      if total_money > 0
        tax = (total_money*0.05 < 5000) ? 5000 : total_money*0.05
        left_money = total_money - tax
        if left_money < 0
          return num 
        else
          num += 1
          check_num(left_money,num)
        end
      else
        return 0
      end
    end

    #对指定对手用指定的卡
    def use_card_on(game_id,card_id,user_id)
      result = Hash.new
      url = "#{BASE_URL}#{RICH_URL}/!api_usertool.php?rt=xml&gid=#{game_id}&rand=#{rand}&tid=#{card_id}&act=use&fuid=#{user_id}"
      doc = http_get_data(url)
      flag = doc.search('//flag').to_a.first.content
      case flag
      when 'suc'
        result.update({
          :success => true,
          :msg     => doc.search('//msg').to_a.first.content
        })
        result.update({:userover => true}) unless doc.search('//userover/item').to_a.empty?
      when 'err'
        result.update({
          :success => false,
          :msg     => doc.search('//error').to_a.first.content
        })
      end
      result
    end

    def line_items(game_id)
      url = "#{BASE_URL}#{RICH_URL}/!api_usertool.php?rt=xml&gid=#{game_id}&rand=#{rand}&act=ing"
      doc = http_get_data(url)
      items = doc.search('//item').to_a.map{|node| node.children.inject({}){|a,c| a[c.name] = c.text if c.class == Nokogiri::XML::Element; a}}
    end

    def make_item(game_id,item_id)
      result = Hash.new
      url = "#{BASE_URL}#{RICH_URL}/!api_usertool.php?rt=xml&gid=#{game_id}&rand=#{rand}&act=create&tid=#{item_id}"
      doc = http_get_data(url)
      flag = doc.search('//flag').to_a.first.content
      case flag
      when 'suc'
        result.update({
          :success => true,
          :msg     => doc.search('//msg').to_a.first.content,
          :tid     => doc.search('//tid').to_a.first.content
        })
      when 'err'
        result.update({
          :success => false,
          :msg     => doc.search('//error').to_a.first.content
        })
      end
      result
    end

    def stocks(game_id)
      result = Hash.new
      url = "#{BASE_URL}#{RICH_URL}/!api_stock.php?rt=xml&gid=#{game_id}&r=#{rand}"
      doc = http_get_data(url)
      stocks = doc.search('//item').to_a.map{|node| node.children.inject({}){|a,c| a[c.name] = c.text if c.class == Nokogiri::XML::Element; a}}
    end

  end
end
