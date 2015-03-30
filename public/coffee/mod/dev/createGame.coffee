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
FORM_ID = '#createGameForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
POST_URL = '/mod/dev/create/game'
DEBUG_MODE = false

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		title: 			$("input[name='title']").val().trim()
		description: 	$("textarea[name='description']").val().trim()
		startDate: 		$("input[name='startDate']").val().trim()
		endDate: 		$("input[name='endDate']").val().trim()
		
	formValid = validateForm formData
	
		

	if formValid != true
		# handle error, dont submit
		$('label[for=' +(formValid.for)+']').addClass 'hasInputError'
		$(FORM_ERROR_CLASS).text formValid.msg
		
		if formValid.for == 'description'
			$('textarea[name='+(formValid.for)+']').change () ->
				$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
				$(FORM_ERROR_CLASS).text ""
		else
			$('input[name='+(formValid.for)+']').change () ->
				$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
				$(FORM_ERROR_CLASS).text ""
			
		$('#submit').shakeIt()
		
	else
		$('#submit').text 'Submitting...'
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
		displayEnd 'Game creation success!', 'Return to the <a href="/mod/dev">Game Development page</a> to add missions!'
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
	