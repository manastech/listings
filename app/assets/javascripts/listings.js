//= require jquery-throttle.js
var selected_items = {};

$(function(){
  var search_query = '.search-query';
  var batchSelectionLastStatus = {};

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
    batchSelectionLastStatus[this['id']] = 'none'
  });

  $(window).bind('change', '#batch-selection', function(e) {
    var checkbox = $(e.target);
    // Selector in bind is not filtering anything for some reason :(
    if (!checkbox.is('#batch-selection')) {
      return;
    }

    var listingElement = checkbox.closest('.listing')[0];
    var listingName = listingElement['id'];
    var status = (checkbox.is(':checked') || batchSelectionLastStatus[listingName] == 'some');

    $(listingElement).find('.checkbox-selection').each(function(){
      $(this).prop("checked", status).change();
    });



  });


  $(window).bind('change', '.checkbox-selection', function(e) {
    // Selector in bind is not filtering anything for some reason :(
    if (!$(e.target).hasClass('checkbox-selection')) {
      return;
    }

    var checkbox = $(e.target);
    var listingElement = checkbox.closest('.listing')[0];
    var listingName = listingElement['id'];
    var listingSelectedItems = selected_items[listingName];
    toggleRowToSelectedRows(checkbox[0].value, listingSelectedItems, checkbox.is(':checked'));
    setIndeterminateStateIfRequired($(listingElement), listingSelectedItems, listingName);
  });

  $(window).on('ajaxComplete', function(event, xhr, status) {
    reloadCheckboxes();
  });

  function setIndeterminateStateIfRequired(listingElement, listingSelectedItems, listingName) {
    var batchSelectionCheckbox = listingElement.find('#batch-selection');
    var totalRowCount = listingElement.find('.checkbox-selection').length;
    var selectedRowCount = listingElement.find('.checkbox-selection:checked').length;

    var zeroSelected = listingSelectedItems.length == 0;
    var allSelected = selectedRowCount == totalRowCount;

    if (zeroSelected) {
      batchSelectionCheckbox[0].indeterminate = false;
      batchSelectionCheckbox.prop("checked", false);
      batchSelectionLastStatus[listingName] = 'none';
    }

    if (allSelected) {
      batchSelectionCheckbox[0].indeterminate = false;
      batchSelectionCheckbox.prop("checked", true);
      batchSelectionLastStatus[listingName] = 'all';
    }

    if (!allSelected && ! zeroSelected) {
      batchSelectionCheckbox[0].indeterminate = true;
      batchSelectionLastStatus[listingName] = 'some';
    }
  }

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


