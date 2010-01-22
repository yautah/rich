require 'logger'

class Appenv
  attr_accessor :config
  def initialize 
    @signs={}  # 信号量,应该也属于运行状态
    @status={} # 运行状态
    @config={} 
    @session={} 
    @request={}

    logfilename = "log/log#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
    @status[:logfilename] = logfilename
    @logger=Logger.new(logfilename,5,1024*1024)
    @logger.level = Logger::INFO
    @logger.datetime_format="%Y%m%d%H%M%S"
  end

  def set_debug(needdebug=true)
    @status[:debug]=needdebug
    if needdebug && !@debug
      @debug=Logger.new(@status[:logfilename]+".debug",5,1024*1024)
      @debug.level = Logger::INFO
      @debug.datetime_format="%Y%m%d%H%M%S"
      @debug.info "debug启动"
    end
  end

  def debug(msg)
    @debug.info(msg) if is_debuging?
  end

  def is_debuging?
    @status[:debug]
  end

  def open_logfile
    cmd="start notepad #{@status[:logfilename]}"
    system cmd
  end

  def info(msg)
    @logger.info msg
    @debug.info(msg) if is_debuging?
    $stdout.print "."
  end

  def warn(msg)
    @logger.warn(msg)
    @debug.warn(msg) if is_debuging?
    $stdout.puts "."
  end

  def sign_inc(key)
    sign = @signs[key] || 0
    sign = sign + 1
    @signs[key]=sign
    return sign
  end
end
