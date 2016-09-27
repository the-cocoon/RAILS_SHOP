module RailsShopStringBeautifiersHelper
  def string_in_groups_by value, num = 4
    value.to_s.scan(/.{1,#{num}}/).join(' ')
  end
end
