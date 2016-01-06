module ShopHelper
  def money_to_text val
    a, b = val.to_s.split '.'
    return a.to_i if b.to_i.zero?
    val.to_f.round(2).to_s
  end
end
