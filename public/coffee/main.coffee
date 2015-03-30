###

This is where all of the common custom javascript will be implemented. It has
been included in the baseloayout.jade file

Dependencies:
	jQuery
	AngularJS

###


# Dropdown menu ease in and out on click

# Credit: http://stackoverflow.com/questions/12115833/adding-a-slide-effect-to-bootstrap-dropdown
$(".dropdown").on "show.bs.dropdown", (e) ->
	$(this).find ".dropdown-menu"
	.first()
	.stop true, true
	.slideDown 200

# Fixed weird issue when sliding up
# Credit: http://stackoverflow.com/questions/26267207/bootstrap-3-dropdown-slidedown-strange-behavior-when-navbar-collapsed
$(".dropdown").on "hide.bs.dropdown", (e) ->
	e.preventDefault()

	$(this).find ".dropdown-menu"
	.first()
	.stop true, true
	.slideUp 200, () ->
		$(this).parent()
		.removeClass "open"
		


###
jQuery plugin: shakeIt
shake it sh-sh-shake it
###

( ($) -> 
	$.fn.shakeIt = () ->
		theShakenOne = this
		theShakenOne.addClass('shakeText')
		theShakenOne.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend', (e) ->
			theShakenOne.removeClass('shakeText')
		return this
) jQuery