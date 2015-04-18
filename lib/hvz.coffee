###
hvz specific constants/config vars

###

roles = (require './constants').roles
specialUserIds = (require './constants').specialUserIds

module.exports = (app) ->
	return construct app
construct = (app)->
	hvz = 
		roles: roles
		specialUserIds: specialUserIds
	
	hvz.getRoleById = (id)->
		for key, obj of hvz.roles
			if obj.id == id
				return obj.name
		return '?'
		
	return hvz
