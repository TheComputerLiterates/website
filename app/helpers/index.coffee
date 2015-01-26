###
# App-wide helper functions
#
###
	
	
# Returns a message to be outputted describing a Parse error (incomplete list)
exports.getParseError = (error, body) ->
	msg = switch
		when error? then 'Error: Unable to connect to the server.'
		when body.code == 125 then 'Error: Invalid email address.'
		when body.code == 101 then 'Error: Invalid email or password.'
		when body.code == 200 then 'Error: Missing email.' # b/c username = email
		when body.code == 202 then 'Error: Email already in use.' 
		else 'Error ' + body.code + ': ' + body.error 
	
	return msg
	