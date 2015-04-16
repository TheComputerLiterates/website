###
	For /user/cRequestView
	
	Users:
		- comment
		- delete (if creator)
	Mods:
		- comment
		- set status
		- delete any
###

LOADING_GIF = '<div class="icon-loading"></div>'


loadComments = ($commentCont, crId)->
	console.log 'Loading comments for crId ' + crId
	$commentCont.empty()
	$commentCont.append LOADING_GIF
	
	$.ajax
		type: 'POST'
		url: '/user/cRequestView_commentGet'
		data: JSON.stringify 
			crId: crId
		contentType: 'application/json'
		success: (res) ->
			$commentCont.empty()
			if res.success
				if res.body.comments.length > 0
					console.log JSON.stringify res.body.comments, undefined, 2
					html = ''
					for com in res.body.comments
						html += '<div class="cr-comment">' +
							'<span class="cr-comment-user">' + com.userName + '</span>' +
							'<span class="cr-comment-date">' + com.createdAt + '</span>' +
							'<br><span class="cr-comment-text">' + com.text + '</span>' +
							'</div>'
					
					$commentCont.html html
					
					# Clear formResult
					$commentCont.parent().children('.cr-submitComment').children('.formResult').empty()
					
				else
					$commentCont.append '<p class="text-center">No comments</p>'
			else
				console.log res.body
				$commentCont.append '<p class="text-center">Error retrieving comments: ' + res.body.error + '</p>'
				return
		error: () ->
			$commentCont.empty()
			$commentCont.append '<p class="text-center">Error retrieving comments</p>'
			return

#Make content togggleable
$('.cr-header').click ()->
	
	# Minimized icon toggle
	$icon = $(this).find('.glyphicon')
	if $icon.hasClass 'glyphicon-menu-right'
		$icon.removeClass 'glyphicon-menu-right'
		$icon.addClass 'glyphicon-menu-down'
	else if $icon.hasClass 'glyphicon-menu-down'
		$icon.removeClass 'glyphicon-menu-down'
		$icon.addClass 'glyphicon-menu-right'
	
	$content = $(this).parent().children '.cr-content'
	
	# Load new comments
	$content.toggle()
	if $content.is ':visible'
		crId = parseInt $content.attr 'data-crId'
		loadComments $content.find('.cr-comment-container'), crId
		

$('.cr-submitComment').submit (e) ->
	e.preventDefault()
	$comment = $(this).find 'textarea[name="newComment"]'
	$content = $(this).closest '.cr-content'
	$formResult = $(this).children '.formResult'
	$submit = $(this).find 'button[type="submit"]'
	$commentCont = $(this).parent().children '.cr-comment-container'
	
	crId = parseInt $content.attr 'data-crId'
	$formResult.empty()
	
	formData =
		comment: 	$comment.val().trim()
		crId:			crId
	
	$comment.prop 'disabled', true
	
	if !formData.comment?
		$submit.shakeIt()
		$comment.prop 'disabled', false
	else
		$submit.text 'Sending...'
		
		console.log 'DATA= ' + JSON.stringify formData, undefined, 2
		
		
		# submit via ajax
		$.ajax
			type: 'POST'
			url: '/user/cRequestView_commentCreate'
			data: JSON.stringify formData
			contentType: 'application/json'
			success: (res) ->
				if res.success
					$formResult.html '<p>Comment added!</p>'
					$submit.text 'Send'
					$comment.val ''
					loadComments $commentCont, crId
					$comment.prop 'disabled', false
				else
					$formResult.html '<p>Error sending comment: ' + res.body.error + '</p>'
					$submit.text 'Send'
					$comment.prop 'disabled', false
					return
			error: () ->
				$formResult.html '<p>Error sending comment!</p>'
				$submit.text 'Send'
				$comment.prop 'disabled', false
				return
	return
