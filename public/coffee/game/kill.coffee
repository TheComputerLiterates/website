###
	For '/game/kill'
	
	Handles kill submission
###



#Handle form submission
FORM_ID = '#reportKillForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
POST_URL = '/game/kill'
DEBUG_MODE = true

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		HVZID: 			$("input[name='HVZID']").val().trim()
				
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
	re = /^(\d{3})[^\d]{0,1}(\d{3})[^\d]{0,1}(\d{3})$/
	
	#required
	if !fd.HVZID
		return {for: 'HVZID', 	msg: 'Missing HVZID!'}
	
	m = fd.HVZID.match(re)
	
	
	if m == null || m.length != 4
		return {for: 'HVZID', 	msg: 'Invalid HVZID format (123-456-789)!'}
	
	fd.HVZID = parseInt(m[1] + m[2] + m[3])
	
	#nothing wrong
	return true


# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd '<b>Oh no! </b> ' + msg, 'Refresh this page and try resubmitting.'
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd 'Kill reported!', 'The Zombie horde has grown...'
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
		$(FORM_RESULT_CLASS).empty()
		$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
		$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
			$("html, body").animate({ scrollTop: 0 }, 500)
		$('#submit').removeAttr 'disabled'
		.text 'Retry'
	
	return
	