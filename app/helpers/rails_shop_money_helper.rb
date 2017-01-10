module RailsShopMoneyHelper
  def money_round val
    val.to_f.round
  end

  def money_to_text val
    money_round(val)
      .to_s
      .reverse
      .scan(/.{1,3}/)
      .join(' ')
      .reverse
      .gsub(' ', '&nbsp;')
      .html_safe
  end
end
