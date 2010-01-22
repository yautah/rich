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
      player1 = Player.new(login)
      player2 = Player.new(login)
      player3 = Player.new(login)
      player4 = Player.new(login)
      player5 = Player.new(login)
      player6 = Player.new(login)
      player7 = Player.new(login)
      player8 = Player.new(login)
      player9 = Player.new(login)
      player10 = Player.new(login)
      player11 = Player.new(login)
      player12 = Player.new(login)
      player13= Player.new(login)
      player14= Player.new(login)
      player15= Player.new(login)
      player16= Player.new(login)
      player17 = Player.new(login)
      player18= Player.new(login)
      player19= Player.new(login)
      player20= Player.new(login)
      player21= Player.new(login)
      player22= Player.new(login)
      player23= Player.new(login)
      player24= Player.new(login)
      player25= Player.new(login)
      player26= Player.new(login)
      player27= Player.new(login)

      player1.login
      player2.login
      player3.login
      player4.login
      player5.login
      player6.login
      player7.login
      player8.login
      player9.login
      player10.login
      player11.login
      player12.login
      player13.login
      player14.login
      player15.login
      player16.login
      player17.login
      player18.login
      player19.login
      player20.login
      player21.login
      player22.login
      player23.login
      player24.login
      player25.login
      player26.login
      player27.login

      threads = []
      1.upto(27) do |i|
        tplayer = eval("player#{i}")
        thread = Thread.new do
          result = tplayer.make_item(2737539,12)
        end
        threads << thread
      end
      threads.each{|t| t.join}
      
      
    end
    $app.info "========================================="
    $app.info "== 自动开心完成 ==\n"
    #      
    $stdout.puts "\ndone!"
    $app.open_logfile if $app.config[:showlog]
  end
end
Player.go
