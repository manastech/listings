require 'spec_helper'

describe Listings do
  it "does something" do
    assert_parse_filter "author:me", {author: "me"}, ""
    assert_parse_filter "Author:me", {author: "me"}, ""

    assert_parse_filter "101", {}, "101"

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

    assert_parse_filter "album_name:me", {album_name: "me"}, ""
    assert_parse_filter "album_name:'me 2' ", {album_name: "me 2"}, ""

    assert_parse_filter "album_name:me-1", {album_name: "me-1"}, ""
  end

  def assert_parse_filter(text, hash, left_text)
    listing = Listings::Base.new

    filters, s = listing.parse_filter text, hash.keys

    s.should eq(left_text)
    filters.should eq(hash)
  end
end
