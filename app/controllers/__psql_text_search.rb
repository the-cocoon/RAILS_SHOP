# DEPRECATED too slow
#

# Model
include ::PgSearch

pg_search_scope :psql_search_base, against: %w[ title intro content ]

scope :psql_search_simple, -> (term) {
  where(
    "products.title   @@ :text OR
     products.intro   @@ :text OR
     products.content @@ :text",
     text: term
  )
}
# ~ Model

# Controller
def psql_products_search
  @squery = params[:term].to_s.strip

  res = ::Product
    .psql_search_base(@squery)
    .published
    .in_stock
    .simple_sort(params)
    .pagination(params)

  render json: res
end

def psql_products_search2
  @squery = params[:term].to_s.strip

  res = ::Product
    .psql_search_simple(@squery)
    .published
    .in_stock
    .simple_sort(params)
    .pagination(params)

  render json: res
end
# ~ Controller