module ShopHelper
  def money_to_text val
    val.to_f
      .round.to_s
      .reverse
      .scan(/.{1,3}/)
      .join(' ')
      .reverse
      .gsub(' ', '&nbsp;')
      .html_safe
  end
end
