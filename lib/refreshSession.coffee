###
	Updates the roleId and HVZID of the logged in user.
	This runs before the acl in every HTTP request
###

module.exports = (app)->
	app.use (req,res,next) ->	
		user = res.locals.session.user
		
		if user?
			app.models.User.updateSession user.userId
			.then (result)->
				user.roleId = result.roleId
				user.HVZID = result.HVZID
				next()
			, (err)->
				console.log 'Error refreshing session for userId=' + user.userId
				next()
		else
			next()
			