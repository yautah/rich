require 'rubygems'
require 'mechanize' 
require 'hpricot'  
require 'yaml'

require 'kaixin'
require 'rich/rich'
#require 'house/garden'
require 'appenv'
require 'utils'

class Player
  include Kaixin,Rich::Rich

  def self.go
    $app = Appenv.new
    $stdout.print "running"
    $app.info('自动开心程序开始运行')

    if not File.exists?('config/config.yaml')
      $app.info "Please setup the config.yaml for configuration first"
      exit
    end

    conf = Utils.symbolize_keys(YAML::load_file('config/config.yaml'))
    $app.config = conf
    if conf['debug']
      $app.set_debug(true)
      $app.debug(conf)
    end

    logins = conf["logins"] || conf["\357\273\277logins"] ||[]
    logins.each do |login|
      $app.info("处理用户:"+login['email'])
      p login
      player = Player.new(login)
      if player.login
        $app.info("登录成功！\n\n")

        #获取当前所有游戏
        game_ids = player.games


        game_ids.each do |game_id|       
          $app.info("大富翁游戏--#{game_id}，处理开始")

          #获取当前拥有的道具
          current_items = player.current_items(game_id)
          $app.info("当前拥有的道具：#{current_items.empty? ? '无' : ''}")
          current_items.each do |item|
            $app.info("  -- 名称：#{item['name']}, 数量：#{item['mynum']}")
          end

          #获取当前玩家信息，现金和余额
          users_info = player.users_info(game_id)
          $app.info("当前游戏玩家：#{users_info.empty? ? '无' : ''}")
          users_info.each do |user_id,info|
            total_money =  info['save'].to_i + info['cash'].to_i
            tax_card_num = player.check_num(total_money)
            $app.info("  -- 姓名：#{info['name'].ljust(8)}|" +
                      "现金：#{info['cash'].ljust(8)}|" +
                      "存款：#{info['save'].ljust(8)}|" +
                      "总额: #{total_money.to_s.ljust(8)}|" +
            "需查税卡：#{tax_card_num}")

            #判断拥有的查税卡能不能搞定对手，能，则用之
            current_tax_card = current_items.find{|item| item['tid']=='12'}
            if current_tax_card && (current_tax_card['mynum'].to_i >= tax_card_num )
              1.upto(tax_card_num) do |index|
                card_result = player.use_card_on(game_id,12,user_id)
                if card_result[:userover]
                  $app.info(" -- #{info['name']}挂了！ ")
                else
                  $app.info(" -- #{card_result[:msg]} ")
                end
              end
            end
          end



          #=begin
          #查看当前制造的道具
          line_items = player.line_items(game_id)
          $app.info("当前制作的道具：#{line_items.empty? ? '无' : ''}")
          line_items.each do |item|
            $app.info("  -- 名称：#{item['name']}, 剩余时间：#{item['timeleave']}分钟")
          end

          #制作道具 
          if line_items.size<12
            $app.info("开始制作道具：")
            1.upto(2-line_items.size) do |i|
                result = player.make_item(game_id,12)
                if result[:success]
                  $app.info("  -- 制造成功：名称：#{result[:tid]}, 信息：#{result[:msg]}")
                else
                  $app.info("  -- 制造失败：信息：#{result[:msg]}")
                end
                sleep(1)
              end
          end

          #查看股市
          $app.info("查看股市信息：")
          player.stocks(game_id).each do |stock|
            $app.info("  -- 股票名称：#{stock['sname']} | 当前价格：#{stock['price'].ljust(6)}| 涨跌：#{stock['updown'].ljust(6)}| 持有股数：#{stock['holdnum'].ljust(6)}| 平均成本：#{stock['cost']}")
          end

          #单个游戏处理结束
          $app.info("大富翁游戏--#{game_id}，处理结束\n")
          #=end
        end
        #p player.line_items(game_ids.first)
        #p player.make_item(game_ids.first, 12)

        #        $app.info "农场信息:(复制到excel中查看)\n"+player.farms_table
        #       s = player.myseedlist_table
        #       $app.info "#{login['email']}的种子清单\n" + s
        #player.auto_havest
        #player.auto_plough
        #player.auto_farmseed_unified
        #player.auto_steal_all
        #      player.temptest
      end
    end
    $app.info "========================================="
    $app.info "== 自动开心完成 ==\n"
    #      
    $stdout.puts "\ndone!"
    $app.open_logfile if $app.config[:showlog]
  end
end
Player.go
