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

  function clearSelectedItems(listingElement) {
    var listingName = listingElement.attr('id');
    selected_items[listingName] = [];
  }

  $('.scope_link').bind('click', function(e) {
    var listingElement = $(this).closest('.listing');
    clearSelectedItems(listingElement);
  });

  function setIndeterminateStateIfRequired(listingElement, listingSelectedItems, listingName) {
    var batchSelectionCheckbox = listingElement.find('#batch-selection');
    var totalRowCount = listingElement.find('.checkbox-selection').length;
    var selectedRowCount = listingElement.find('.checkbox-selection:checked').length;

    var zeroSelected = listingSelectedItems.length == 0;
    var allSelected = selectedRowCount == totalRowCount;

    if (batchSelectionCheckbox.length == 0) {
      return;
    }

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
      var listingElement = $('.listing#' + bindingId)[0];
      setIndeterminateStateIfRequired($(listingElement), selected_items[bindingId], bindingId);
    });
  }

  $('.listing').on('click', '.filter a', function(e) {
    elem = $(this);
    var listingElement = elem.closest('.listing');
    clearSelectedItems(listingElement);

    var key = elem.data('key');
    var value = elem.data('value');

    var search_data = listingElement.data('search');
    if (search_data.filters[key] == value) {
      delete search_data.filters[key];
    } else {
      search_data.filters[key] = value;
    }

    listingElement.data('search', search_data);
    updateListingFromSearchData(listingElement);
  }).on("listings:loaded", function(e){
    // highlight current filter
    var listingElement = $(this).closest('.listing');
    listingElement.find('.filter.active').removeClass('active');

    var search_data = listingElement.data('search');
    for(key in search_data.filters) {
      listingElement.find('.filter a[data-key=' + searchEscape(key) + '][data-value=' + searchEscape(search_data.filters[key]) + ']').parent().addClass('active');
    }

  });

  function searchEscape(value) {
    if (value == /\w+/) {
      return value;
    } else if (value.indexOf("'") > -1) {
      return '"' + value + '"';
    } else {
      return "'" + value + "'";
    }
  }

  function updateListingFromSearchData(listingElement) {
    s = ""
    search_data = listingElement.data('search');
    for(key in search_data.filters) {
      s += key + ":" + searchEscape(search_data.filters[key])
      s += " ";
    }
    if (search_data.criteria) {
      s += search_data.criteria;
    }

    var search = $(search_query, listingElement);
    search.val(s);
    search.closest('form').submit();
  }
});


function getSelectedRows(name) {
  return selected_items[name];
}

function refreshListing(name) {
  var url = $('#' + name).data('url');
  $.get(url);
}

