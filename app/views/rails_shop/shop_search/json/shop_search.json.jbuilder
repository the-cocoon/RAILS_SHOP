json.array!(@shop_items) do |item|
  json.label item.title
  json.value item.title

  json.url_for        url_for(item)
  json.main_image_url item.main_image_url(:v100x100)
end