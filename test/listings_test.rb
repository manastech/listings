require 'test_helper'

class ListingsTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Listings
  end

  test "parse filter" do

    assert_parse_filter "author:me", {author: "me"}, ""
    assert_parse_filter "Author:me", {author: "me"}, ""

    assert_parse_filter "author:me category:foo", {author: "me", category: "foo"}, ""
    assert_parse_filter "   author:  me    category:  foo", {author: "me", category: "foo"}, ""
    assert_parse_filter "   author:  'me'    category:  foo", {author: "me", category: "foo"}, ""
    assert_parse_filter "   author:  \"me\"    category:  foo", {author: "me", category: "foo"}, ""

    assert_parse_filter "author:me category:foo bar", {author: "me", category: "foo"}, "bar"
    assert_parse_filter "author:me bar category:foo", {author: "me", category: "foo"}, "bar"
    assert_parse_filter "bar author:me category:foo", {author: "me", category: "foo"}, "bar"

    assert_parse_filter "author:\"John Doe\"", {author: "John Doe"}, ""
    assert_parse_filter "author:\"John Doe's\"", {author: "John Doe's"}, ""

    assert_parse_filter "author:'John Doe'", {author: "John Doe"}, ""
    assert_parse_filter "author:'John Doe:s'", {author: "John Doe:s"}, ""

    assert_parse_filter "bar author:'me:s' baz category:\"foo foo\"", {author: "me:s", category: "foo foo"}, "bar baz"

  end

  def assert_parse_filter(text, hash, left_text)
    listing = Listings::Base.new

    filters, s = listing.parse_filter text, hash.keys

    assert_equal s, left_text
    assert_equal filters, hash
  end

end
