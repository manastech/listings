//= require jquery-throttle.js

var selected_items = {};

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

    selected_items[this['id']] = [];
  });

  $('.batch-selection#all').click(function (event) {
    var listingElement = $(this).closest('.listing')[0];
    var listingName = listingElement['id'];
    selected_items[listingName] = [];
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", true);
    });
  });

  $('.batch-selection#none').click(function (event) {
    var listingElement = $(this).closest('.listing')[0];
    var listingName = listingElement['id'];
    selected_items[listingName] = [];
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", false);
    });
  });

  $('.checkbox-selection').change(function() {
    var listingName = $(this).closest('.listing')[0]['id'];
    toggleRowToSelectedRows(this.value, listingName);
  });

  function toggleRowToSelectedRows(colId, listingName) {
    var listingSelectedItems = selected_items[listingName];
    var index = listingSelectedItems.indexOf(colId);
    if (index > -1) {
      listingSelectedItems.splice(index, 1);
    } else {
      listingSelectedItems.push(colId);
    }
  }
});


function getSelectedRows(name) {
  return selected_items[name];
}

function refreshListing(name) {
  var url = $('#' + name).data('url');
  $.get(url);
}


