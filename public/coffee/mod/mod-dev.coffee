###
For '/mod/dev'

Handles general game dev viewing.

Dependencies:
	jQuery


###

FADE_TIME = 100

dtSettings =
	order: [[0, 'asc']]
	aLengthMenu: [[25, 50, 75, -1], [25, 50, 75, "All"]]
	iDisplayLength: 25
	autoWidth: true


$(document).ready ()->
	refresh()

refresh = ()->
	$('.dataTable').DataTable dtSettings