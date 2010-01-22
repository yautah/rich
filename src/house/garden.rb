require 'utils'
require 'json/pure'
module House
  module Garden
    include ::Utils,::Kaixin
    
    GARDEN_URL_PART = "/!house/!garden"
    
    #花园信息
    def getconf(fuid=0)
      url = "#{BASE_URL}#{GARDEN_URL_PART}/getconf.php?verify=#{@verify}&fuid=#{fuid}&r=0.#{rand(10000000000000000)}"
      page = http_get_data(url)
      doc = Hpricot.parse(page.body)
      doc
    end
    
    #农场信息
    def get_farms(doc = nil)
      doc = getconf unless doc
      farms = []
      doc.search("//garden/item").each do |item|
        farm = {}
        item.search("/*").each do |node|
          farm[node.name.to_sym] = node.inner_text
        end
        farms << farm
      end
      farms
    end
    
    # 需收获?
    def farm_need_havest?(farm)
      return farm[:cropsstatus].to_s=='2'
    end
    
    # 自动收获
    def auto_havest()
      get_farms.each do |farm|
        if farm_need_havest?(farm)
          url = "#{BASE_URL}#{GARDEN_URL_PART}/havest.php?farmnum=#{farm[:farmnum]}&fuid=0&seedid=0&r=#{rand}"
          page = http_get_data(url)
          doc = Hpricot.parse(page.body)
          if doc.search("//data/ret")[0].inner_text=='succ'
            $app.info "收获"+(farm[:fuid]=='-1' ? '自种' : "#{farm[:friendname]}在爱心地种") + "的#{farm[:name]}#{farm[:fruitnum]}个"
          else
            $app.info "警告:收获"+(farm[:fuid]=='-1' ? '自种' : "#{farm[:friendname]}在爱心地种") + "的#{farm[:name]}失败!!!"
          end    
        end
      end
    end
    def can_steal(farm)
      #作物还没有成熟不能偷
      return false if farm[:cropsstatus].to_s!='2'  
      #不是自己种的爱心地不能偷
      if farm[:shared]=='1'
        if farm[:fuid]==@uid
          return true
        else
          return false
        end
      end

      return false if farm[:crops]=~/再过.*可偷/
      return false if farm[:crops]=~/已偷过/
      
      return false if ['114','115','116'].include?(farm[:seedid].to_s) #曼陀罗
      
      #21 人参,22 冬虫夏草,24 灵芝,104-108 曼珠沙华,182 缅栀,117-119 绣球花
      return false if ['21','22','24','104','105','106','107','108','117','118','119','182'].include?(farm[:seedid]) && farm[:wapcropspercent]=~/剩余1/
      
      return true
    end
    # 偷菜
    def steal_havest(friend)
      fuid = friend['uid']
      conf = getconf(fuid)
      sleeptime = conf.search("//conf/account/setting/sleeptime")[0].inner_text
      if  sleeptime == '2' 
        s_now = Time.at(conf.search("//conf/ctime")[0].inner_text.to_i).strftime('%H%M')
        if s_now > '0200' && s_now< '0600' 
          $app.info "#{friend['real_name']}家休息时间,不能偷"
          return
        end
      end
      get_farms(conf).each do |farm|
        if can_steal(farm)
          url = "#{BASE_URL}#{GARDEN_URL_PART}/havest.php?farmnum=#{farm[:farmnum]}&fuid=#{fuid}&seedid=0&r=#{rand}"
          page = http_get_data(url)
          doc = Hpricot.parse(page.body)
          if get_str_from_doc(doc,"//data/anti")=='1'
            $app.warn "警告:花园精灵捣乱,无法偷东西了,请手工登陆清除"
            return 
          end
          ret = get_str_from_doc(doc,"//data/ret")
          if ret=='succ'
            seedname = get_str_from_doc(doc,"//data/seedname")
            stealnum = get_str_from_doc(doc,"//data/stealnum")
            $app.info "在#{friend['real_name']}家偷得#{seedname}#{stealnum}个"
          else
            fail_count = $app.sign_inc('steal_havest_fail_count')
            $app.warn "警告:在#{friend['real_name']}家偷#{seedname}失败,原因:#{doc.search("//data/reason")[0]}"
            $app.warn  "ret:#{ret}"
            $app.warn doc.to_s
            $app.warn farm 
            if "2点到6点是休息时间，请天亮再来偷吧" =~ doc.search("//data/reason")[0]
              break
            end
            exit if fail_count > 10
          end
        end
      end
    end

    #自动偷所有人的菜
    def auto_steal_all
      friendlist.each do |f|
        $app.info "考察#{f['real_name']}家的菜地"
        steal_havest(f)
      end
    end
    
    # 需锄地?
    def farm_need_plough?(farm)
      return farm[:cropsstatus].to_s=='3' && farm[:shared].to_s!='1'
    end
    
    # 自动锄地
    def auto_plough
      get_farms.each do |farm|
        if farm_need_plough?(farm) 
          url = "#{BASE_URL}#{GARDEN_URL_PART}/plough.php?farmnum=#{farm[:farmnum]}&fuid=0&seedid=0&r=#{rand}"
          page = http_get_data(url)
          doc = Hpricot.parse(page.body)
          ret = doc.search("//data/ret")[0].inner_text
          if ret=='succ'
            $app.info "锄#{farm[:farmnum]}号地"
            $app.info doc.search("//data/cashtips")[0].inner_text if doc.search("//data/cashtips").size >0 
          else
            $app.debug "锄地时发生错误,body="+page.body
          end
        end
      end
    end
    
    # 需播种?
    def farm_need_farmseed?(farm)
      return farm[:shared]!='1' && farm[:status]=='1' && (farm[:seedid]==nil || farm[:seedid]=='') && (farm[:cropsstatus]==nil || farm[:cropsstatus]=='')
    end
    
    # 自动播种
    def auto_farmseed(seed=nil)
      get_farms.each do |farm|
        if farm_need_farmseed?(farm) 
          picked_seed = seed || pick_seed()
          if picked_seed
            url = "#{BASE_URL}#{GARDEN_URL_PART}/farmseed.php?farmnum=#{farm[:farmnum]}&fuid=0&seedid=#{picked_seed[:seedid]}&r=#{rand}"
            http_get_data(url)
            $app.info "在#{farm[:farmnum]}号地播种#{picked_seed[:name]}"
          end
        end
      end
    end
    
    # 自动播种同一种农作物
    def auto_farmseed_unified
      picked_seed = pick_seed()
      if picked_seed
        auto_farmseed(picked_seed)
      end
    end
    
    #选种子,可提供多种选中策略
    def pick_seed(seeds=nil)
      seeds = get_myseedlist unless seeds
      return send(@user[:pick_seed_method],seeds)
    end
    
    #选数量最多的种子
    def pick_seed_maxnum(seeds)
      max,picked_seed =0,nil
      seeds.each{|s| max,picked_seed = s[:num].to_i,s if s[:num].to_i>max}
      picked_seed
    end
    
    #根据种子名选种子
    def pick_seed_by_seedname(seeds)
      seedname=@user[:seedname]
      seeds.each{|s| if s[:name]== seedname then return s end }
      return nil
    end
    
    # 打印出农场信息,直接粘贴到excel查看
    def farms_table
      hash_as_table(get_farms)
    end
    
    #第一页我的种子清单doc
    def myseedlist(page=1)
      url = "#{BASE_URL}#{GARDEN_URL_PART}/myseedlist.php?verify=#{@verify}&page=#{page}&r=#{rand}"
      page = http_get_data(url)
      doc = Hpricot.parse(page.body)
      doc
    end
    
    #所有我的种子清单doc array
    def myseedlist_all
      result=[]
      doc = myseedlist
      result << doc
      
      totalpage_elements = doc.search("/data/totalpage")
      return result if totalpage_elements.size==0
      totalpage = totalpage_elements[0].inner_text.to_i
      if totalpage > 1
        (2..totalpage).each{|page| result<< myseedlist(page)} 
      end
      result
    end
  
    #我的种子清单数据hash
    def get_myseedlist(docs=nil)
      docs = myseedlist_all unless docs
      seeds = []
      docs.each do |doc|
        doc.search("//data/seed/item").each do |item|
          seed = {}
          item.search("/*").each do |node|
            seed[node.name.to_sym] = node.inner_text
          end
          seeds << seed
        end
      end
      $app.debug "我的种子:\n"+hash_as_table(seeds)
      seeds
    end
    
    #我的种子表格
    def myseedlist_table
      hash_as_table(get_myseedlist)
    end
    
    
    #种子清单doc
    def seedlist_doc
      url = "#{BASE_URL}#{GARDEN_URL_PART}/seedlist.php?verify=#{@verify}&r=#{rand}"
      page = http_get_data(url)
      doc = Hpricot.parse(page.body)
      doc
    end
    
    #种子清单数据hash
    def seedlist_doc2hasharray(doc)
      seeds = []
      doc.search("//data/seed/item").each do |item|
        seed = {}
        item.search("/*").each do |node|
          seed[node.name.to_sym] = node.inner_text
        end
        seeds << seed
      end
      seeds
    end
    
    #种子表格
    def seedlist_table
      hash_as_table(seedlist_doc2hasharray(seedlist_doc))
    end

    # 好友hash
    def friendlist
      url = "#{BASE_URL}#{GARDEN_URL_PART}/friendlist.php?verify=#{@verify}&r=#{rand}"
      page = http_get_data(url)
      doc = ::JSON.parse(page.body)
      doc
    end
    
    def temptest
      puts seedlist_table
    end
  end
end
