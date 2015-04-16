###
	For /user/cRequestView
	
	Users:
		- comment
		- delete (if creator)
	Mods:
		- comment
		- set status
		- delete any
###

TOGGLE_SPEED = 500

#Make content togggleable
$('.cr-header').click ()->
	$(this).parent().children('.cr-content').toggle()
	
	$icon = $(this).find('.glyphicon')
	
	if $icon.hasClass 'glyphicon-menu-right'
		$icon.removeClass 'glyphicon-menu-right'
		$icon.addClass 'glyphicon-menu-down'
	else if $icon.hasClass 'glyphicon-menu-down'
		$icon.removeClass 'glyphicon-menu-down'
		$icon.addClass 'glyphicon-menu-right'
	