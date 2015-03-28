###
for /mod/dev/create/game

Handles new game submission

###

###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###



#Handle form submission
FORM_ID = '#createMissionForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
POST_URL = '/mod/dev/create/mission'
DEBUG_MODE = false

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		gameId:			parseInt $('select[name="gameId"]').val()
		title: 			$("input[name='title']").val().trim()
		description: 	$("textarea[name='description']").val().trim()
		startDate: 		$("input[name='startDate']").val().trim()
		endDate: 		$("input[name='endDate']").val().trim()
		visibility:
			human: $('input[name="visibility"][data-group="human"]').is ':checked'
			zombie: $('input[name="visibility"][data-group="zombie"]').is ':checked'
			oz: $('input[name="visibility"][data-group="oz"]').is ':checked'
	
	formValid = validateForm formData
	
	if formValid != true
		# handle error, dont submit
		$('label[for=' +(formValid.for)+']').addClass 'hasInputError'
		$(FORM_ERROR_CLASS).text formValid.msg
		$('[name='+(formValid.for)+']').change () ->
			$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
			$(FORM_ERROR_CLASS).text ""
			
		$('#submit').shakeIt()
		
	else
		$('#submit').text 'Submitting...'
		
		# Prepare datetime for mariadb
		formData.startDate = (formData.startDate.replace 'T', ' ') + ':00'
		formData.endDate = (formData.endDate.replace 'T', ' ') + ':00'
		
		console.log 'DATA= ' + JSON.stringify formData, undefined, 2
		# submit via ajax
		$.ajax
			type: 'POST'
			url: POST_URL
			data: JSON.stringify formData
			contentType: 'application/json'
			success: (res) ->
				if res.success
					endInSuccess()
				else
					endInError(res.msg)
					return
			error: () ->
				endInError()
				return
					
		
	return


#checks values for correct input, returns true or an error string
validateForm = (fd) ->
	
	#required
	if !fd.title						then return {for: 'title', 		msg: 'Missing title!'}
	else if !fd.description			then return {for: 'description', msg: 'Missing description!'}
	else if !fd.startDate			then return {for: 'startDate', 	msg: 'Missing start date!'}
	else if !fd.endDate				then return {for: 'endDate', 		msg: 'Missing end date!'}
	
	#Check visibility
	if !fd.visibility.human && !fd.visibility.zombie && !fd.visibility.oz
		return {for: 'visibility', 		msg: 'Must be visible to at least one group'}
	else if !fd.visibility.human && !fd.visibility.zombie
		if !confirm 'Are you sure you want to make this OZ only?'
			return {for: 'visibility', 		msg: 'Add the Human and/or Zombie group!'}
	else if !fd.visibility.oz
		if !confirm 'Are you sure you want to exclude the OZ group?'
			return {for: 'visibility', 		msg: 'Add the OZ group!'}
			
	#Create date objects
	d1 = Date.parse fd.startDate
	d2 = Date.parse fd.endDate
	now = Date.now() - 86400000 #yesterday
	
	if d1 < now
		return {for: 'endDate', msg: 'Start date cannot be in the past!'}
	else if !(d1 < d2)
		return {for: 'endDate', msg: 'End date must succeed start date!'}
	
	
	#nothing wrong
	return true


# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd '<b>An unexpected error has occured:</b> ' + msg, 'Refresh this page and try resubmitting.'
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd 'Mission creation success!', 'Return to the <a href="/mod/dev">Game Development page</a> to view the new mission, or refresh this page to add another!'
	return
displayEnd = (header, subtext) ->
	if !DEBUG_MODE
		$(FORM_ID+' input').attr('disabled','disabled');
		$(FORM_ID+' checkbox').attr('disabled','disabled');
		$(FORM_ID+' select').attr('disabled','disabled');
		$(FORM_ID).fadeTo 1000, 0, ()->
			#create message
			$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
			$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
				$("html, body").animate({ scrollTop: 0 }, 500)
			return
	else
		$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
		$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
			$("html, body").animate({ scrollTop: 0 }, 500)
		$('#submit').removeAttr 'disabled'
		.text 'Retry'
	
	return
	