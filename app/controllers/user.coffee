module.exports = (app) ->
	class app.UserController
		@profile = (req, res) ->

			userRole

			for roles, role of app.locals.hvz.roles
				if role.id == parseInt req.session.user.roleId
					userRole = role.name
					break

			res.render 'user/profile',
				title: 'User - Profile'
				firstname: req.session.user.firstName
				lastname: req.session.user.lastName
				email: req.session.user.email
				hvzid: req.session.user.HVZID
				role: userRole
				

		@forum = (req, res) ->
			res.render 'user/forum',
				title: 'User - Forum'
		
		@stats = (req, res) ->
			res.render 'user/stats',
				title: 'User - Statistics'
		
		@logout = (req,res)->
			req.session.user = undefined
			res.redirect '/'