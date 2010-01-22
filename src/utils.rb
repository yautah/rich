
module Utils
  #hash转换为文本表格
  def hash_as_table(hash)
    keys=[]
    hash.each do |el|
      keys << el.keys
    end
    keys = keys.flatten.uniq.sort{|a,b| a.to_s<=>b.to_s}
    result = ''
    result<<keys.join("\t")
    hash.each{|f| result<< "\n"+keys.collect{|k| f[k]}.join("\t")}
    result
  end
  def get_str_from_doc(doc,xpath)
    return '' unless doc || xpath
    elements = doc.search(xpath)
    return '' if elements.size == 0
    return elements[0].inner_text
  end
  def symbolize_keys(hash)
    result = {}
    hash.each do |k,v| 
      if v === Hash
        v = symbolize_keys(v)
      end
      result[k.to_sym],result[k] = v,v 
    end
    return result
  end
  def Utils.symbolize_keys(hash)
    result = {}
    hash.each do |k,v| 
      if v === Hash
        v = symbolize_keys(v)
      end
      result[k.to_sym],result[k] = v,v 
    end
    return result
  end
end
