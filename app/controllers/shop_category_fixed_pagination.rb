class ShopCategoryFixedPagination
  def initialize(conn, params)
    @conn  = conn
    @page  = params[:page] || 1
    @limit = 24
  end

  def current_page
    @page.to_i
  end

  # Manual calculation of pages
  def total_pages
    sql = <<-EOS.squish
      SELECT
         COUNT(RES.*)
      FROM
         (
            SELECT
               shop_category_rels.item_id   AS item_id,
               shop_category_rels.item_type AS item_type
            FROM
               "shop_category_rels"
            WHERE
               (
                  "shop_category_rels"."item_amount" != 0
               )
               AND "shop_category_rels"."item_state" = 'published'
            GROUP BY
               item_id,
               item_type
         ) AS RES
      ;
    EOS

    records = @conn.execute(sql).getvalue(0,0)
    (records.to_f / @limit.to_f).ceil
  end

  def limit_value
    @limit
  end

  def offset
    (@page - 1) * @limit
  end
end
