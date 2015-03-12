###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###


#Handle form submission
FORM_ID = '#loginForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		email: 				$("input[name='email']").val().trim()
		password: 			$("input[name='password']").val().trim()
		
	formValid = validateForm formData

	if formValid != true
		# handle error, dont submit
		$('label[for=' +(formValid.for)+']').addClass 'hasInputError'
		$(FORM_ERROR_CLASS).text formValid.msg
		
		if formValid.for == 'year'
			$('select[name='+(formValid.for)+']').change () ->
				$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
				$(FORM_ERROR_CLASS).text ""
		else
			$('input[name='+(formValid.for)+']').change () ->
				$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
				$(FORM_ERROR_CLASS).text ""
			
		$('#submit').shakeIt()
		
	else
		$('#submit').text 'Submitting...'
		#Encrypt password (1st encryption. 2nd is server-side)
		formData.password = CryptoJS.SHA3 formData.password, {outputLength: 512}
			.toString CryptoJS.enc.Hex
		
		#submit via ajax
		$.ajax
			type: 'POST'
			url: '/login'
			data: JSON.stringify formData
			contentType: 'application/json'
			success: (res) ->
				if res.success
					endInSuccess()
				else
					endInError(res.msg)
					return
			error: () ->
				endInError 'Check your internet connection and try again.'
				return
					
		
	return


#checks values for correct input, returns true or an error string
validateForm = (fd) ->
	#required
	if !fd.email				then return {for: 'email', 		msg: 'Missing email!'}
	else if !fd.password		then return {for: 'password', 	msg: 'Missing password!'}
	
	#nothing wrong
	return true


# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd '<b>Error!</b>', msg, false
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd 'Signup Complete!', 'You may login now', true
	return
displayEnd = (header, subtext, hide) ->
	#create message
	$(FORM_RESULT_CLASS).empty()
	$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
	$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
		$("html, body").animate({ scrollTop: 0 }, 500)
	
	if hide
		$(FORM_ID+' input').attr('disabled','disabled');
		$(FORM_ID+' checkbox').attr('disabled','disabled');
		$(FORM_ID+' select').attr('disabled','disabled');
		$(FORM_ID+' button').attr('disabled','disabled');
		$(FORM_ID).fadeTo 1000, 0
	else
		$('#submit').removeAttr 'disabled'
		.text 'Submit'
	
	return
	