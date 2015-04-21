###
For '/mod/users'

Handles user management.

Dependencies:
	jQuery

Datatable uses
	- Can disable certain columns
	- Can navigate with arrow keys + hit return for easy button calls
	
TODO
	- Make the buttons small icons
	- Add datatable KeyTable support

###

FADE_TIME = 100
$iconLoading = $('.icon-loading')
$iconLoading.toggle false

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
	runAction $(this)
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


runAction = ($btn)->
	$iconLoading.toggle true
	
	data =
		action: $btn.attr 'data-action'
		userId: parseInt $btn.attr 'data-userId'
	
	# Disable other buttons for this user
	$('.btn-action[data-userId="'+data.userId+'"]').attr 'disabled', true
	$btn.text '...'
	
	# Handle additional data collection
	switch data.action
		when 'changeRole' then data.roleId = parseInt $btn.attr 'data-roleId'
	
	# Log it
	logEvent '[ACTION_RUN] ' + JSON.stringify data
	
	#Call it
	$.ajax
		type: 'POST'
		url: '/mod/users'
		data: JSON.stringify data
		contentType: 'application/json'
		success: (res) ->
			$iconLoading.toggle false
			if res.success
				logEvent '[ACTION_SUCCESS] action="'+data.action+'" userId='+data.userId
				$btn.text 'SUCCESS!'
			else
				logEvent '[ACTION_ERROR] action="'+data.action+'" userId='+data.userId+' err="'+res.msg+'"'
				$btn.text 'ERROR!'
				return
		error: (err) ->
			$iconLoading.toggle false
			logEvent '[ACTION_ERROR_LOCAL] action="'+data.action+'" userId='+data.userId+' err="'+err+'"'
			$btn.text 'ERROR!'
			return
	
