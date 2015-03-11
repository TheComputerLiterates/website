###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###

$("#login").submit (e) ->
	e.preventDefault()

	data =
		email: $("[name='email']").val()
		password: CryptoJS.SHA256 $("[name='password']").val()
			.toString CryptoJS.enc.Hex

	$.ajax
		url: "/login"
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