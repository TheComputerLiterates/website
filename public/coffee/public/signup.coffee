###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###



#Handle form submission
FORM_ID = '#signupForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
DEBUG_MODE = false

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		firstName: 			$("input[name='firstName']").val().trim()
		lastName: 			$("input[name='lastName']").val().trim()
		email: 				$("input[name='email']").val().trim()
		emailConfirm: 		$("input[name='emailConfirm']").val().trim()
		password: 			$("input[name='password']").val().trim()
		passwordConfirm: 	$("input[name='passwordConfirm']").val().trim()
		emailSubscribed: 	$("input[name='emailSubscribed']").is ':checked'
		
		
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
		
		#Remove input confirms
		formData.emailConfirm = undefined
		formData.passwordConfirm = undefined
		
		#Encrypt password (1st encryption. 2nd is server-side)
		formData.password = CryptoJS.SHA3 formData.password, {outputLength: 512}
			.toString CryptoJS.enc.Hex
		
		#submit via ajax
		$.ajax
			type: 'POST'
			url: '/signup'
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
	#regex validation email
	regE = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		
	
	#required
	if !fd.firstName										then return {for: 'firstName', 	msg: 'Missing first name!'}
	else if !fd.lastName									then return {for: 'lastName', 	msg: 'Missing last name!'}
	else if !fd.email										then return {for: 'email', 		msg: 'Missing email!'}
	else if !regE.test(fd.email)						then return {for: 'email', 		msg: 'Valid email required!'}
	else if !fd.emailConfirm							then return {for: 'email', 		msg: 'Missing email confirmation!'}
	else if fd.email != fd.emailConfirm				then return {for: 'email', 		msg: 'Emails do not match!'}
	else if !fd.password									then return {for: 'password', 	msg: 'Missing password!'}
	else if !fd.passwordConfirm						then return {for: 'password', 	msg: 'Missing password confirmation!'}
	else if fd.password != fd.passwordConfirm		then return {for: 'password', 	msg: 'Passwords do not match!'}
	
	
	#nothing wrong
	return true


# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd '<b>An unexpected error has occured:</b> ' + msg, 'Refresh this window and try resubmitting.'
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd 'Signup Complete!', 'You may login now'
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
	