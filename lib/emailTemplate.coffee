###
# Sends email using the email-templates and mandrill libraries
# @param eName = templateDirName (string)
# @param eData = relevant sending data (see example)
###
emailTemplates = require 'email-templates'
path = require 'path'

module.exports = (app) ->
	app.emailTemplates = emailTemplates
	app.emailTemplate = (eName,eData) ->
		# EXAMPLE eData
		# eData =
		# 	to_email: 'jrdbnntt@gmail.com'
		# 	from_email: 'account@hvzatfsu.com'
		# 	from_name: 'HvZ at FSU'
		# 	subject: 'Account Created!'
		# 	locals:
		# 		firstName: "Jared"
		# 		lastName: "Bennett"
		# 	success: function(to_email) #called after mandrill success
		# 	error: function(to_email) #called after mandrill error
		def = app.Q.defer()
		
		console.log 'Sending email...'	
		templatesDir = path.resolve(__dirname,'..', 'emails')
		app.emailTemplates templatesDir,  (err, template) ->
			if err
				console.log err
			else
				locals = eData.locals
				Render = (locals) ->
					this.locals = locals
					this.send = (err,html,text) ->
						if !err
							console.log ' > Email-templates - Creation success'
							message = 
								html: html
								text: text
								subject: eData.subject
								from_email: eData.from_email
								from_name: eData.from_name
								to: [
									email: eData.to_email
									name: if eData.locals.firstName || 
										eData.locals.lastName then eData.locals.firstName + 
										' ' + eData.locals.lastName else eData.to_email
									type: 'to'
								]	
								
							app.mandrill.messages.send 'message': message, 'async': true, 
								(result) ->
									console.log ' > Mandrill - Email Sent Success - subject="'+ eData.subject+'" to_email= ' + eData.to_email
									if eData.success
										eData.success(eData.to_email)
										def.resolve()
								, (e) ->
									console.log ' > Mandrill - Error: ' + e.name + ' - ' + e.message
									if eData.error
										eData.error(eData.to_email)
									def.reject()
						else
							console.log ' > Email-templates - Error: ' + err
							def.reject()
							
					this.batch = (batch) ->
						batch this.locals, templatesDir, this.send
					
					return
				
				template eName, true, (err, batch) ->
					if this.err
						console.log this.err
					else
						render = new Render(locals)
						render.batch(batch)
					return
				return
			return
		return def.promise
	return