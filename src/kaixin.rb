require 'rubygems'
require 'mechanize' 
require 'hpricot'  

module Kaixin
  BASE_URL = 'http://www.kaixin001.com/'
  def initialize(user)
    @user=symbolize_keys(user)
    @user[:pick_seed_method]||='pick_seed_maxnum'
    if @user[:pick_seed_method]=='pick_seed_by_seedname'
      @user[:seedname]=(@user[:seedname]&&@user[:seedname].strip)||"牧草"
    end
    @agent = WWW::Mechanize.new
    if @user[:agent]
      @agent.user_agent_alias = @user[:agent]  
      $app.debug "采用#{@user[:agent]}浏览器"
    end
    @agent.redirect_ok = true
    @agent.user_agent_alias = 'Windows IE 6' 
    @agent.max_history = 2
    @agent.open_timeout = 10
  end
  def http_get_html(url)
    page = @agent.get(url) 
    raise "url is null" if page.body == nil || page.body == ''
    page
  end
  def http_get_data(url)
    page = @agent.get(url) 
    raise "url is null" if page.body == nil || page.body == ''
    $app.debug("url:#{url}")
    $app.debug("page.body:#{page.body}")
    page
  end

  def login

    if File.exists?("cache/#{@user[:email]}.yml")
      @agent.cookie_jar.load("cache/#{@user[:email]}.yml")
      $app.info("Cookie文件存在，从cookie登录！")
      return true
    else
      page = @agent.get(BASE_URL) 
      form = page.form(:name=>'loginform'){|f|
        f.url='/home/'
        f.email = @user[:email]
        f.password = @user[:password]
      }
      page = form.submit

      url = "#{BASE_URL}/!house/index.php?_lgmode=pri&t=27"
      page = http_get_html(url)

      url = "#{BASE_URL}/!house/garden/index.php"
      page = http_get_html(url)
      if page.body=~/验证码/
        $app.warn "!!警告:被要求提供验证码"
        return false
      end
      verify = /g_verify = "(.+)";/i.match(page.body).to_a[1]
      uid = /g_im_vuid = (.+);/i.match(page.body).to_a[1] 

      verify = /g_verify = "(.+)";/i.match(page.body).to_a[1]
      if verify ==nil || verify == '' ||uid==nil || uid == ''
        $app.warn page.body
        $app.warn "!!警告:系统异常,请检查"
        return false
      end

      @verify,@uid = verify,uid
      $app.debug "verify:#{@verify},uid:#{@uid}"
      @agent.cookie_jar.save_as("cache/#{@user[:email]}.yml")
      $app.info("无Cookie文件，以用户名密码登录！")
      return true
    end
  end
  def logout
    url = "#{BASE_URL}/login/logout.php"
    http_get_html(url)
  end
end
