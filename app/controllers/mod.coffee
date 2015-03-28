module.exports = (app) ->
	class app.ModController
		@index = (req, res) ->
			res.render 'mod/index',
				title: 'Mod Tools - Home'
		
		@dev = (req, res) ->
			res.render 'mod/dev',
				title: 'Mod Tools - Develop Games'
				
		@game = (req, res) ->
			res.render 'mod/game',
				title: 'Mod Tools - Current Game'
		
		@info = (req, res) ->
			res.render 'mod/info',
				title: 'Mod Tools - Edit Info'
		
		@users = (req, res) ->
			
			p = app.models.User.getAllBasic()
			p.then (userData)->
				console.log 'Success getting users!'
				
				# Get counts
				counts = 
					user: 0
					active: 0
					human: 0
					zombie: 0
					OZ: 0
					mod: 0
				
				for user in userData
					switch user.role
						when 'U' then ++counts.user
						when 'H' then ++counts.human
						when 'Z' then ++counts.zombie
						when 'O' then ++counts.OZ
						when 'M' then ++counts.mod
					
						
					if user.active == 0
						user.active = 'N'
					else
						++counts.active
						user.active = 'Y'
					
						
				res.render 'mod/users',
					title: 'Mod Tools - Manage Users'
					userData: userData
					counts: counts
			, (err)->
				console.log 'Error getting users'
			
			
			