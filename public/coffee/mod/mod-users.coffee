###
For '/mod/users'

Handles user management.

Dependencies:
	jQuery
	socket.io
	AngularJS 

###

dtSettings =
	order: [[0, 'asc']]
	aLengthMenu: [[25, 50, 75, -1], [25, 50, 75, "All"]]
	iDisplayLength: 25
	autoWidth: true

$(document).ready ()->
	$('#DT').DataTable dtSettings