###
	For /signup form page

	Dependencies:
		JQeury
		CryptoJS
###

$("#signup").submit (e) ->
	e.preventDefault()

	data =
		firstName: $("#firstName").val()
		lastName: $("#lastName").val()
		username: $("#username").val()
		email: $("#email").val()
		password: CryptoJS.SHA256 $("#password").val()
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