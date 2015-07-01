// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require listings
//= require_tree .

// Test for triggered 'loaded' event
// $(function() {
//   $('.listing').on('listings:loaded', function(event, el) {
//     console.log('Loaded');
//     console.log(el);
//   });
// });

$(function(){

  $('.listing').on('change', '#date-filter', function(){
    var listings = $(this).closest('.listing')
    var filter = $(this);

    if (filter.val() == '') {
      listings.trigger("listings:filter:key:clear", filter.data('filter-key'))
    } else {
      listings.trigger("listings:filter:key:set", [filter.data('filter-key'), filter.val()])
    }
  });
});

