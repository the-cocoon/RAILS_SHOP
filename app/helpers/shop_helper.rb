module ShopHelper
  def money_to_text val
    # a, b = val.to_s.split '.'
    # return a.to_i if b.to_i.zero?
    val.to_f
      .round.to_s
      .reverse
      .scan(/.{1,3}/)
      .join(' ')
      .reverse
      .gsub(' ','&nbsp;')
      .html_safe
  end
end
