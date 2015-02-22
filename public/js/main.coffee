###

This is where all of the common custom javascript will be implemented. It has
been included in the baseloayout.jade file 

###


# Get Current Game Info for information bar

$(document).ready ->
	getData = ->
		$.ajax
			url: "/data/currentgame"
			type: "POST"
			ajax: "true"
			success: (res) ->
				if res.gameActive == true
					$("#gameStats").html "Current Game Info | Humans: " + res.humancount + " | Zombies: " + res.zombiecount
				else
					$("#gameStats").html "There is no game being played currently"
	getData()
	setInterval(getData, 5000)

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