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

Create listings files `app/listings/{{name}}_listing.rb`. See [listings samples](#Samples) and the [dsl](#Listings dsl)

Use `render_listing` helper to include the listing by its `name`.


```ruby
# file: app/listings/tracks_listing.rb
class TracksListing < Listings::Base
  ...
end
```

```
= render_listing :tracks_courses
```

## Samples

For a Track/Album model:

```
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

## Listings dsl

A listing inherits from `Listings::Base` and defines de following dsl

### model

`model` can me used with just and `ActiveRecord` class:

```ruby
  model Track
```

or with a block to perform further operations.

```ruby
  model do
  	Tracks.favorites
  end
```

or generata an array of objects or hashes

```ruby
  model do
  	[
  	{title: "Tishomingo Blues", album: {name: "The Royal J's" }},
  	{title: "Save me for later", album: {name: "Me 'n' Mabel" }}
  	]
  end
```

### column

Declaring a `column` with a symbol renders that attribute. 

```ruby
  column :title
```

`column` accept options. By default `{ searchable: false, sortable: true }`

Adding `searchable: true` will make a search box appear and perform a search depending on the datasource logic (`field LIKE '%pattern%'` for ActiveRecord datasource or `include?` for Object datasource)

```ruby
  column :title, searchable: true
```

`column` can traverse object path and `belongs_to` relations.

```ruby
  column album: :name
```

Or

```ruby
  column [:album, :name]
```

`column` also accepts a block to alter the rendering of the field.

```ruby
  column album: :name do |track, album_name|
  	album_name.titleize
  end
```

### scopes

### filter

### paginate

### css

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