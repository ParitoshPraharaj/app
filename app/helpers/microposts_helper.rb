module MicropostsHelper
  def wrap(content)
    sanitize(raw(content.split.map {|s| wrap_long_string(s)}.join(' ')))
  end
  
  private
  def wrap_long_string(text, max_size=30)
    zero_width_space="&#8203;"
    regex=/.{1,#{max_size}}/
    (text.length<max_size)? text : text.scan(regex).join(zero_width_space)
  end
end