# ::ThinkingSphinx.search("canon", star: true, classes: [ Product ], indices: %w[ product_core ]).count
# ::ThinkingSphinx.search("canon", star: true, classes: [ Product ], indices: %w[ admin_product_core ]).count

ThinkingSphinx::Index.define :product, with: :active_record do
  indexes title
  indexes intro
  indexes content

  indexes fts_auto_data
  indexes fts_manual_data

  where "state = 'published' AND amount > 0"
end