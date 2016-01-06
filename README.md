git clean -f -n

# RailsShop

1.

MIGRATIONS::
  > rake rails_shop_engine:install:migrations

2.

rake db:migrate

3.

routes

```
Rails.application.routes.draw do
  # ... your routes

  RailsShop::Routes.mixin(self)

  # ... your routes
end
```

4.

```
  link(href='https://fonts.googleapis.com/css?family=Open+Sans&subset=latin,cyrillic' rel='stylesheet' type='text/css')
  link(href='//maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css'   rel='stylesheet' type='text/css')
```

```
= render template: 'rails_shop/carts/cart_btn'
```

5.

```
class User < AR
  include ::RailsShop::User
end
```