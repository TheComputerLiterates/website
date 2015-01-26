/*!
 * This is where all of the common custom javascript will be implemented. It has
 * been included in the main index.volt file 
 */


// Dropdown menu ease in and out on click


// Credit: http://stackoverflow.com/questions/12115833/adding-a-slide-effect-to-bootstrap-dropdown
$('.dropdown').on('show.bs.dropdown', function(e){
  $(this).find('.dropdown-menu').first().stop(true, true).slideDown(200);
});

// Fixed weird issue when sliding up
// Credit: http://stackoverflow.com/questions/26267207/bootstrap-3-dropdown-slidedown-strange-behavior-when-navbar-collapsed
$('.dropdown').on('hide.bs.dropdown', function(e){
  e.preventDefault();
  $(this).find('.dropdown-menu').first().stop(true, true).slideUp(200, function(){
    $(this).parent().removeClass('open');
  });
});


