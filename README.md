# Listings
By [Manas](https://github.com/manastech)

[![Build Status](https://travis-ci.org/manastech/listings.svg?branch=master)](https://travis-ci.org/manastech/listings)

Listings aims to simplify the creations of listings for Rails 3 & 4 apps.

The listings created support when approriate sorting, pagination, scoping, searching, filtering and exports to csv or xls.

A listing data source have built in support for ActiveRecord and Arrays.

* [Listings](#listings)
    * [Download](#download)
    * [Configuration](#configuration)
    * [Usage](#usage)
    * [Samples](#samples)
    * [Listings DSL](#listings-dsl)
      * [model](#model)
      * [column](#column)
      * [scope](#scope)
      * [filter](#filter)
      * [paginates_per](#paginates_per)
      * [export](#export)
      * [css](#css)
    * [Testing](#testing)
    * [i18n](#i18n)
    * [Templates](#templates)
    * [Javascript api](#javascript-api)
    * [Under the hood](#under-the-hood)
    * [License](#license)

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

Require assets in your Javascript and Stylesheet

```
//= require listings
```

```
 *= require listings
```

Create `config/initializers/listings.rb` file to make general configurations. Listings plays nice with twitter bootstrap 2 & 3 without explicitly including it.

```ruby
# file: config/initializers/listings.rb
Listings.configure do |config|
  config.theme = 'twitter-bootstrap-3' # defaults to 'twitter-bootstrap-2'
  config.push_url = true # User html5 history push_state to allow back/forward navigation. defaults to false
end
```

## Usage

Create listings files `app/listings/{{name}}_listing.rb`. See [listings samples](#samples) and the [DSL](#listings-dsl)

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
    Track.favorites
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

> **computed columns**
>
> Listings will try to sort and filter by default using the `<table_name>.<column_name>` field of the query, on computed queries this will not work, you will need to use `column :my_computed_field, query_column: :my_computed_field` to allow sorting and filtering.
>
> Using computed columns might cause some issues depending on the Kaminari version used. If this is the case and you need to filter based on a computed filed, you will need to define a `custom_filter` to apply the filtering of the computed field.
>
> See example at [spec/dummy/app/listings/authors_listing.rb](spec/dummy/app/listings/authors_listing.rb)

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

A `values: :method` can be specified to avoid the select distinct over the values.

```ruby
  filter album: :name, values: :all_album_names, title: 'Album' do |album_name|
    album_name.titleize
  end

  def all_album_names
    Album.order("name").pluck("distinct name").reject(&:nil?)
  end
```

Also `render:` option can be used to suppress the rendering of the filter, but allowing the user to filter by it. For example to filter by the id:

```ruby
  filter :id, render: false
```

Or `render:` can be user to indicate the partial to be used for rendering that filter. Hence allowing custom UI for certain filter among the default UI. See [Templates](#templates) for information regarding where the partial will be looked.

```ruby
  filter :update_at, render: 'date'
```


Filters are rendered by default by the side of the listing. With `layout` method you can change this and render them on the top.

```ruby
  layout filters: :top
```

Custom filters allows definition of custom meaning to a key. This filters are not rendered by default. Use `render:` option to indicate the partial to be used for rendering.

```ruby
  custom_filter :order_lte do |items, value|
    items.where('"order" <= ?', value.to_i)
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

### export

Declare which formats you want to be available for export. Notice that paging will be ignored for the export.

```ruby
  export :csv, :xls
```

Sometimes the columns should be rendered different for the export a `format` property is available and will be `:html`, `:csv` or `:xls`.

```ruby
  column :email do |user, email|
    if format == :html
      mail_to email
    else
      email
    end
  end
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

## Testing

Include `listings/rspec` in your `spec_helper.rb`

```ruby
# file: spec/spec_helper.rb
require 'listings/rspec'
```

Ensure listing is able to render

```ruby
# file: spec/listings/tracks_listing_spec.rb
require 'spec_helper'

RSpec.describe TracksListing, type: :listing do
  let(:listing) { query_listing :tracks }

  it 'should get tracks' do
    # ... data setup ...
    items = listing.items.to_a
    # ... assert expected items ...
  end
end
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

The listing content can be reloaded preserving current sort, scope, search, filter and page.

To reload the listings rendered by

```
= render_listing :tracks
```

use

```javascript
refreshListing('tracks')
```

Change filters

```
$('#tracks.listings').trigger("listings:filter:key:clear", 'album_name')
$('#tracks.listings').trigger("listings:filter:key:set", ['album_name', 'Best of'])
```

## View Helpers

Use `render_listing` helper to include the listing by its `name`.

```
= render_listing :tracks
```

Use `listings_link_to_filter` helper to render a link that will set a filter. Used to example when you want the user to be able to click on a cell value to filter upon that.

```ruby
  column artist: :name do |album, value|
    listings_link_to_filter(value, :artist_id, album.artist_id)
  end
```


## Templates

There are a number of templates involved in rendering the listing. These templates can be rendered by the hosting app per listing or theme basis.

For example if a listing named `tracks` is rendered with `twitter-bootstrap-3` theme the templates are looked up in the following locations/order:

 * `<app>/views/listings/tracks/<partial>`
 * `<gem>/views/listings/tracks/<partial>`
 * `<app>/views/listings/twitter-bootstrap-3/<partial>`
 * `<gem>/views/listings/twitter-bootstrap-3/<partial>`
 * `<app>/views/listings/<partial>`
 * `<gem>/views/listings/<partial>`

This lookup logic is inside `Listings::ActionViewExtensions#listings_partial_render`.

## Under the hood

The first listing is rendered in the context of the request, so the first page will be displayed with no delay.

Any further interaction with the listing will end up in a AJAX call attended by the mountable engine.


## License

listings is Copyright © 2003 Manas Technology Solutions. It is free software, and may be redistributed under the terms specified in the LICENSE file.
