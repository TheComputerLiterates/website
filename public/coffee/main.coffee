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


# Loads game data for bar
$(document).ready ()->
	$bar = $('#gameStats')
	$bar.text 'Loading game stats..'
	
	$.ajax
		type: 'POST'
		url: '/data/getGameStatus'
		data: JSON.stringify {}
		contentType: 'application/json'
		success: (res) ->
			if res.success
				if res.data.gameTitle?
					$bar.text res.data.gameTitle + ' | ' + 
						res.data.hCount + ' Humans ' + 
						res.data.zCount + ' Zombies'
				else
					$bar.text "No game is being played"
					
			else
				$bar.text 'Error loading game stats'
				return
		error: () ->
			$bar.text 'Unable to load game stats'
			return