###
For '/mod/users'

Handles user management.

Dependencies:
	jQuery
	socket.io
	AngularJS 

Datatable uses
	- Can disable certain columns
	- Can navigate with arrow keys + hit return for easy button calls
	
TODO
	- Make the buttons small icons
	- Add datatable KeyTable support

###

FADE_TIME = 100
$iconLoading = $('.icon-loading')

dtSettings =
	order: [[0, 'asc']]
	aLengthMenu: [[25, 50, 75, -1], [25, 50, 75, "All"]]
	iDisplayLength: 25
	autoWidth: true
	dom: 'C<"clear">lfrtip'
	colVis:
		buttonText: 'Show/Hide'
		activate: 'click'
		exclude: [0,1]



$(document).ready ()->
	table = $('#DT').DataTable dtSettings
	# keys = new $.fn.dataTable.KeyTable table
	
	return

$('.btn-action').click ()->
	act = $(this).attr 'data-action'
	userId = $(this).attr 'data-userId'
	
	console.log 'BTN ' + act + ' FOR ' + userId	
	
	action[act] userId, $(this)
	return
	

##############################################################################
# Actions
$log = $('#log')
logEvent = (text)->
	d = new Date()
	h = d.getHours()
	m = d.getMinutes()
	s = d.getSeconds()
	
	#add leading 0 if needed
	h = if h < 10 then '0'+h else h
	m = if m < 10 then '0'+m else m
	s = if s < 10 then '0'+s else s
		
	time = '<b>[' + h + ':' + m + ':' + s + ']</b> '
	$log.append '<span>' + time + text + '</span><br>'
	$log.scrollTop $log[0].scrollHeight
logEvent '~~LOG START~~'

action = 
	killUser: (userId, $btn)->
		$iconLoading.fadeTo FADE_TIME, 1
		logEvent 'action= killUser\nuserId= '+userId
		
		return true
	reviveUser: (userId, $btn)->
		logEvent 'action= reviveUser\nuserId= '+userId
	deleteUser: (userId, $btn)->
		logEvent 'action= deleteUser\nuserId= '+userId
	activateUser: (userId, $btn)->
		logEvent 'action= activateUser\nuserId= '+userId
	deactivateUser: (userId, $btn)->
		logEvent 'action= deactivateUser\nuserId= '+userId
		$iconLoading.fadeTo FADE_TIME, 0
	editUser: (userId, $btn)->
		logEvent 'action= editUser\nuserId= '+userId
	flagUser: (userId, $btn)->
		logEvent 'action= flagUser\nuserId= '+userId
	commentUser: (userId, $btn)->
		logEvent 'action= commentUser\nuserId= '+userId
	
