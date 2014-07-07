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
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", true).change();
    });
  });

  $('.batch-selection#none').click(function (event) {
    var listingElement = $(this).closest('.listing')[0];
    var listingName = listingElement['id'];
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", false).change();
    });
  });

  $('.checkbox-selection').change(function() {
    var listingName = $(this).closest('.listing')[0]['id'];
    var listingSelectedItems = selected_items[listingName];
    toggleRowToSelectedRows(this.value, listingSelectedItems, $(this).is(':checked'));
  });

  function toggleRowToSelectedRows(colId, listingSelectedItems, checked) {
    var index = listingSelectedItems.indexOf(colId);
    var present = index > -1;
    if (checked && !present) {
      listingSelectedItems.push(colId);
    }
    if (!checked && present) {
      listingSelectedItems.splice(index, 1);
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


