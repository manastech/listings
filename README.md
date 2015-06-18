# Listings
By [Manas](https://github.com/manastech)

[![Build Status](https://travis-ci.org/manastech/listings.svg?branch=master)](https://travis-ci.org/manastech/listings)

Listings aims to simplify the creations of listings for Rails 3 & 4 apps.

The listings created support when approriate sorting, pagination, scoping, searching, filtering and exports to csv or xls.

A listing data source have built in support for ActiveRecord and Arrays.

## Download

Add `listings` to your Gemfile:

```ruby
gem 'listings'
```

## Configuration

Mount listings engine to in you `config/routes.rb`

```ruby
Rails.application.routes.draw do
  ...
  mount Listings::Engine => "/listings"
end
```

Create `config/initializers/listings.rb` file to make general configurations. Listings plays nice with twitter bootstrap 2 & 3 without explicitly including it.

```ruby
# file: config/initializers/listings.rb
Listings.configure do |config|
  config.theme = 'twitter-bootstrap-3' # defaults to 'twitter-bootstrap-2'
end
```

## Usage

Create listings files `app/listings/{{name}}_listing.rb`. See [listings samples](#Samples) and the [DSL](#Listings DSL)

Use `render_listing` helper to include the listing by its `name`.


```ruby
# file: app/listings/tracks_listing.rb
class TracksListing < Listings::Base
  ...
end
```

```
= render_listing :tracks
```

## Samples

For a Track/Album model:

```ruby
class Track < ActiveRecord::Base
  belongs_to :album
  attr_accessible :order, :title

  scope :favorites, -> { ... }
end

class Album < ActiveRecord::Base
  attr_accessible :name
  has_many :tracks
end
```

a listing with

```ruby
class TracksListing < Listings::Base
  model Track

  scope :all
  scope :favorites

  filter album: :name

  column :order
  column :title, searchable: true
  column album: :name, searchable: true
end
```

## Listings DSL

A listing inherits from `Listings::Base` and defines de following DSL

### model

`model` can be used with just an `ActiveRecord` class

```ruby
  model Track
```

or with a block to perform further operations

```ruby
  model do
    Tracks.favorites
  end
```

or generate an array of objects or hashes

```ruby
  model do
    [
      {title: "Tishomingo Blues", album: {name: "The Royal J's" }},
      {title: "Save me for later", album: {name: "Me 'n' Mabel" }}
    ]
  end
```

### column

Declaring a `column` with a symbol renders that attribute

```ruby
  column :title
```

`column` accepts options. By default `{ searchable: false, sortable: true }`

Adding `searchable: true` will make a search box appear and perform a search depending on the datasource logic (`field LIKE '%pattern%'` for ActiveRecord datasource or `include?` for Object datasource)

```ruby
  column :title, searchable: true
```

`column` can traverse object path and `belongs_to` relations

```ruby
  column album: :name
```

Or

```ruby
  column [:album, :name]
```

`column` also accepts a block to alter the rendering of the field

```ruby
  column album: :name do |track, album_name|
    album_name.titleize
  end
```

The block is evaluated in a view_context so any helper you will usually use in a view it can be used in the block

```ruby
  column do |track|
    link_to 'Edit', edit_track_path(track)
  end

  column do |track|
    # renders app/views/shared/_tracks_actions view
    render partial: 'shared/track_actions', locals: {track: track}
  end
```

`column` also accepts a `title:` option

```ruby
  column album: :name, title: 'Album'
```

### scope

Declaring a `scope` with a symbol with allow user to show only records matching the scope in the ActiveRecord class

```ruby
  scope :favorites
```

You can change the displayed name but yet, using the declared scope

```ruby
  scope 'My favorites', :favorites
```

If you don't want to pollute the model with scopes, or you need to filter items with a custome logic use a block

```ruby
  scope 'My favorites', :favorites, lambda { |items| items.where(...) }
```

### filter

Declaring a `filter` will display a unique list of values of the field and allow the user to filter on exact match

```ruby
  filter album: :name
```

It supports `title:` and a block

```ruby
  filter album: :name, title: 'Album' do |album_name|
    album_name.titleize
  end
```

### paginates_per

Page size can be specified by `paginates_per`

```ruby
  paginates_per 40
```

And you can disable pagination

```ruby
  paginates_per :none
```

### css

`css_class` ca specify a css class to be apply to the listing

```ruby
  css_class 'my-custom-style'
```

`row_style` can specigy a css class to apply to each row depending on the item it is rendering

```ruby
  row_style do |track|
    'favorite-track' if track.favorite?
  end
```

A `column` also support a `class` option to specify a css class to be applied on every table cell

```ruby
  column :title, class: 'title-style'
```

## i18n

Although titles can be specified in the listing definition, i18n support is available. Add to your locales:

```yml
es:
  listings:
    no_data: "No se encontraron %{kind}"
    export: "Descargar"
    search_placeholder: "Buscar %{kind}"
    records: "registros"
    headers:
      tracks:
        title: 'Título'
        album_name: 'Nombre del Album'
```

## Javascript api
TBD

## Under the hood

The first listing is rendered in the context of the request, so the first page will be displayed with no delay.

Any further interaction with the listing will end up in a AJAX call attended by the mountable engine.


## License

listings is Copyright © 2003 Manas Technology Solutions. It is free software, and may be redistributed under the terms specified in the LICENSE file.
