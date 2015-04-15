###
	For /user/cRequestCreate
	
	Handles form submission + mission option display
###



##############################################################################
# Handle form submission

FORM_ID = '#cRequestCreateForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
POST_URL = '/user/cRequestCreate'
DEBUG_MODE = true
RESULT_MESSAGES=
	successTitle: 'Clarification request created!'
	successSubtitle: '<a href="/user/cRequestView">Return</a>'
	errorTitle: '<b>An unexpected error has occured:</b> '
	errorSubtitle: 'Refresh this page and try resubmitting.'

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		subject: 		$("input[name='subject']").val().trim()
		description: 	$("textarea[name='description']").val().trim()
		visibileToAll: $('input[type="radio"][name="visibileToAll"]:checked').val() == 'true'
		gameId:			$('select[name="gameId"]').val()
		missionId:		$('select[name="missionId"]').val()
		
	#Handle ids
	formData.gameId = if isNaN(formData.gameId) then undefined else parseInt formData.gameId
	formData.missionId = if isNaN(formData.missionId) then undefined else parseInt formData.missionId
	
	console.log JSON.stringify formData, undefined, 2
	
	formValid = validateForm formData
	
	if formValid != true
		# handle error, dont submit
		$('label[for=' +(formValid.for)+']').addClass 'hasInputError'
		$(FORM_ERROR_CLASS).text formValid.msg
		$('[name='+(formValid.for)+']').change () ->
			$('label[for=' +$(this).attr('name')+']').removeClass 'hasInputError'
			$(FORM_ERROR_CLASS).text ""
			
		$('#submit').shakeIt()
		
	else
		$('#submit').text 'Submitting...'
		
		console.log 'DATA= ' + JSON.stringify formData, undefined, 2
		# submit via ajax
		# $.ajax
		# 	type: 'POST'
		# 	url: POST_URL
		# 	data: JSON.stringify formData
		# 	contentType: 'application/json'
		# 	success: (res) ->
		# 		if res.success
		# 			endInSuccess()
		# 		else
		# 			endInError(res.msg)
		# 			return
		# 	error: () ->
		# 		endInError()
		# 		return
	return

#checks values for correct input, returns true or an error string
validateForm = (fd) ->
	#required
	if !fd.subject						then return {for: 'subject', 		msg: 'Missing subject!'}
	else if !fd.description			then return {for: 'description', msg: 'Missing description!'}
	
	#nothing wrong
	return true


# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd  RESULT_MESSAGES.errorTitle + msg, RESULT_MESSAGES.errorSubtitle
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd RESULT_MESSAGES.successTitle, RESULT_MESSAGES.successSubtitle
	return
displayEnd = (header, subtext) ->
	if !DEBUG_MODE
		$(FORM_ID+' input').attr('disabled','disabled');
		$(FORM_ID+' checkbox').attr('disabled','disabled');
		$(FORM_ID+' select').attr('disabled','disabled');
		$(FORM_ID).fadeTo 1000, 0, ()->
			#create message
			$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
			$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
				$("html, body").animate({ scrollTop: 0 }, 500)
			return
	else
		$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
		$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
			$("html, body").animate({ scrollTop: 0 }, 500)
		$('#submit').removeAttr 'disabled'
		.text 'Retry'
	
	return


##############################################################################
# Option managment
` //CREDIT: http://stackoverflow.com/questions/4398966/how-can-i-hide-select-options-with-javascript-cross-browser
(function($){

    $.fn.extend({detachOptions: function(o) {
        var s = this;
        return s.each(function(){
            var d = s.data('selectOptions') || [];
            s.find(o).each(function() {
                d.push($(this).detach());
            });
            s.data('selectOptions', d);
        });
    }, attachOptions: function(o) {
        var s = this;
        return s.each(function(){
            var d = s.data('selectOptions') || [];
            for (var i in d) {
                if (d[i].is(o)) {
                    s.append(d[i]);
                    //console.log(d[i]);
                    // TODO: remove option from data array
                }
            }
        });
    }});   

})(jQuery);
`

$gSelect = $('select[name="gameId"]')
$mSelect = $('select[name="missionId"]')

$mSelect.detachOptions('[for="missionId"]')

$gSelect.on 'change', ()->	
	gameId = this.value
	$mSelect.detachOptions('[for="missionId"]')
	$mSelect.attachOptions('[for="missionId"][value="None"]')
	
	if isNaN gameId
		$mSelect.attr 'disabled', 'disabled'
	else
		$mSelect.removeAttr 'disabled'
		$mSelect.attachOptions('[for="missionId"][data-gameId="'+gameId+'"]')
	
	
	$mSelect.val 'None'
	