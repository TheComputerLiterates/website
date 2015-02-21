###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###

$("#signup").submit (e) ->
	e.preventDefault()

	data =
		firstName: $("[name='firstName']").val()
		lastName: $("[name='lastName']").val()
		email: $("[name='email']").val()

	if $("[name='password']").val().length != 0
		data.password = CryptoJS.SHA256 $("[name='password']").val()
			.toString CryptoJS.enc.Hex

	$.ajax
		url: "/signup"
		type: "POST"
		ajax: "true"
		data: JSON.stringify data
		cache: false
		contentType: "application/json"
		processData: false
		success: (res) ->
			$("#test").html res
		error: (res) ->
			$("#test").html "Error!"