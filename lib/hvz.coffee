###
hvz specific constants/config vars

###

roles = (require './constants').roles

module.exports = (app) ->
	return construct app
construct = (app)->
	hvz = 
		roles: roles
	
	hvz.getRoleById = (id)->
		for key, obj of hvz.roles
			if obj.id == id
				return obj.name
		return '?'
		
	return hvz
