# 自动开心程序
kaixin001.com中买房子送花园组件中的花园自动化

# 使用方法
用记事本打开config.yaml
填入email和password 
运行autokaixin.exe


# 已实现的功能                                                    
自动收获全部成熟的农作物                                         
自动锄地(用户自己的地,爱心地不能除地)                            
自动播种,目前提供两种选种方案,在config.yaml中配置                
  pick_seed_maxnum :挑选种子最多的播种                           
  pick_seed_by_seedname:根据种子名选种子,同时还要设置参数seedname
自动偷菜
收获自己在好友家中的爱心地                                                         
可以设置多个用户,系统轮流处理                                    
                                                                 
# 计划中的功能                                                    
好友的爱心地锄地                                                 
播种爱心地                                                   
自动摇钱
人参娃娃遍历(?)
浇水,捉虫


# 配置文件参数说明
## 以#开头的是注释
## ignore_bom: 避免用window的记事本编辑config.yaml以后保存为utf8时的BOM问题而在第一个行添加的无用元素
固定为
 ignore_bom: true
## logins: 用户信息
### 参照email,password,pick_seed_method的格式可以写多个用户
例如
	logins:
	  - email: YOUR_EMAIL1@EMAIL.COM
	    password: YOUR_KAIXIN_PASSWORD1
	    pick_seed_method: pick_seed_by_seedname
	    seedname: 牧草
	  - email: YOUR_EMAIL2@EMAIL.COM
	    password: YOUR_KAIXIN_PASSWORD2
	    pick_seed_method: pick_seed_maxnum
### email: 登陆的电子邮件地址
### password: 开心网密码
	    
### pick_seed_method: 挑选种子的方法(用于自动播种的时候)
可用值:
  pick_seed_maxnum: 挑选种子最多的播种
  pick_seed_by_seedname: 根据种子名选种子,同时还要设置参数seedname

### agent: 使用的浏览器,如果有很多小号,尽量每个用户都使用不同的agent避免需要验证码
可用值有
	Windows IE 6
	Windows IE 7
	Windows Mozilla
	Mac Safari
	Mac FireFox
	Mac Mozilla
	Linux Mozilla
	Linux Konqueror
	iPhone
	Mechanize
默认为Mechanize

## showlog: 是否程序结束时自动打开log文件

## debug: 是否处于调试状态
可用值: true|false
如果debug: true,系统会打印调试信息到 .log.debug中,里面有每次访问服务器的url及返回的数据

#自动运行,加入一个计划任务(通过gui操作好像不行)
schtasks /create /tn "autokaixin" /tr E:\prog\autokaixin\autokaixin.exe /sc minute /mo 30 /ru "system"


# 谢谢使用
对该程序有任何想法请联系autokaixin(at)gmail.com
记得加我为好友 uid=60322153 :) Enjoy it!
