module.exports = (app) ->
	class app.UserController
		@profile = (req, res) ->
			res.render 'user/profile',
				title: 'User - Profile'
				firstname: req.session.user.firstName
				lastname: req.session.user.lastName
				email: req.session.user.email
				hvzid: req.session.user.HVZID
				role: app.hvz.getRoleById req.session.user.roleId
				

		@forum = (req, res) ->
			res.render 'user/forum',
				title: 'User - Forum'
		
		@stats = (req, res) ->
			res.render 'user/stats',
				title: 'User - Statistics'
		
		@logout = (req,res)->
			req.session.user = undefined
			res.redirect '/'