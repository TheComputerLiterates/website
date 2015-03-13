###
	Handles ACL, run before each HTTP reqest.
	Blocks request if not allowed. Only checks for restriced paths
###

roles = (require './hvz').roles

module.exports = acl = (req,res,next) ->	
	isAllowedAccess = true
	
	path = req.path.split '/'
	
	switch path[1]
		when 'user'
			if !res.locals.session.user? || res.locals.session.user.roleId < roles.USER.id
				isAllowedAccess = false
		when 'game' # Human vs Zombie vz OZ dertermined by the page
			if !res.locals.session.user? || res.locals.session.user.roleId < roles.OZ.id
				isAllowedAccess = false
		when 'mod'
			if !res.locals.session.user? || res.locals.session.user.roleId < roles.MODERATOR.id
				isAllowedAccess = false
				
	if isAllowedAccess
		next()
	else
		# Does not have access to this page
		res.redirect '/login'