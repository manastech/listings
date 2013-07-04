//= require jquery-throttle.js

$(function(){
  var search_query = '.search-query';

  $('.listing').each(function(){
    var listing = $(this);
    
    var listing_search_submit = $.debounce(function(){
      var search = $(search_query, listing);
      search.closest('form').submit();
    }, 250, null, true);

    listing.on('keyup', search_query, function(){
      listing_search_submit();
    })
  });
});

function refreshListing(name) {
  var url = $('#' + name).data('url');
  $.get(url);
}