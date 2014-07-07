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


  $(window).bind('click', '.batch-selection#all', function(e) {
    // Selector in bind is not filtering anything for some reason :(
    if (!$(e.target).is('#all')) {
      return;
    }

    var link = $(e.target);
    var listingElement = link.closest('.listing')[0];
    var listingName = listingElement['id'];
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", true).change();
    });
  });

  $(window).bind('click', '.batch-selection#none', function(e) {
    // Selector in bind is not filtering anything for some reason :(
    if (!$(e.target).is('#none')) {
      return;
    }

    var link = $(e.target);
    var listingElement = link.closest('.listing')[0];
    var listingName = listingElement['id'];
    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", false).change();
    });
  });

  $(window).bind('change', '.checkbox-selection', function(e) {
    // Selector in bind is not filtering anything for some reason :(
    if (!$(e.target).hasClass('checkbox-selection')) {
      return;
    }

    var checkbox = $(e.target);
    var listingName = checkbox.closest('.listing')[0]['id'];
    var listingSelectedItems = selected_items[listingName];
    toggleRowToSelectedRows(checkbox[0].value, listingSelectedItems, checkbox.is(':checked'));
  });

  $(window).on('ajaxComplete', function(event, xhr, status) {
    reloadCheckboxes();
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

  function reloadCheckboxes() {
    $.each(selected_items, function(bindingId) {
      $.each(selected_items[bindingId], function(index, checkboxValue) {
        $('.listing#' + bindingId).find('.checkbox-selection[value=\'' + checkboxValue + '\']').prop("checked", true);
      })
    });
  }
});



function getSelectedRows(name) {
  return selected_items[name];
}

function refreshListing(name) {
  var url = $('#' + name).data('url');
  $.get(url);
}


