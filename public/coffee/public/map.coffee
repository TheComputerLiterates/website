###
	For /map
		- displays custom google map
	Data Variables
		geofences
		geopoints
###
console.log geopoints
console.log geofences

$iconLoading = $('.icon-loading')
.toggle false

$info = $('#info')

resetInfo = ()->
	$info.empty
	$info.html '<tr><td colspan="2" class="text-center"><i>Hover over an element to see its description</i></td></tr>'
setInfo = (description, color)->
	$info.empty()
	$info.html '
		<tr>
			<td class="col-xs-2" '+(if color? then 'style="background-color:'+color+';"')+'></td>
			<td class="col-xs-10">
				'+description+'
			</td>
		</tr>'

##############################################################################
# Displaying the map
# http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html?utm_medium=twitter

ID_STATUS = '#status'

ID_MAP_CANVAS = 'map-canvas'
geopointIcon = 'img/icons/mapLocation-small.png'

pt_fsu =  new google.maps.LatLng(30.442795, -84.298563)
map = null
mapCircles = []
mapMarkers = []	

# Uses current state of geopoints and geofences
placeMapData = ()->
	# Delete any old ones
	i = 0
	for c in mapCircles
		c.setMap null
	for m in mapMarkers
		m.setMap null
		
	mapCircles = []
	mapMarkers = []
	
	console.log '---------------------'
	for gp in geopoints
		console.log 'GP=' + JSON.stringify gp
		marker = new google.maps.Marker
				position: new google.maps.LatLng gp.latitude, gp.longitude
				map: map
				icon: geopointIcon
		google.maps.event.addListener marker, 'mouseover', ()->
			setInfo gp.description
		
		mapMarkers.push marker
	for gf in geofences
		console.log 'GF=' + JSON.stringify gf
		circle = new google.maps.Circle
			strokeColor: gf.color
			strokeWeight: 0
			fillColor: gf.color
			fillOpacity: 0.35
			center: new google.maps.LatLng gf.latitude, gf.longitude
			radius: gf.radius
			map: map
		google.maps.event.addListener circle, 'mouseover', ()->
			setInfo gf.description
		mapCircles.push circle
		
	$(ID_STATUS + ' .geopoints').text 'Active Geopoints: ' + geopoints.length 
	$(ID_STATUS + ' .geofences').text 'Active Geofences: ' + geofences.length

initMap = ()->
	CUSTOM_MAPTYPE_ID = 'custom_style'
	featureOpts = [
		{
			stylers: [
				{ hue: '#2e2b21' }
				{ visibility: 'simplified' }
				{ gamma: 0.5 }
				{ weight: 1 }
				{ invert_lightness: false }
			]
		}
		{
			elementType: 'labels'
			stylers: [
				{ visibility: 'off' }
			]
		}
		{
			featureType: 'water'
			stylers: [
				{ color: '#9cbebd' }
			]
		}
	]
	
	styledMapOptions =
		name: 'Custom Style'
		
	customMapType = new google.maps.StyledMapType featureOpts, styledMapOptions
	
	mapOptions = 
		center: pt_fsu
		zoom: 16
		# mapTypeControlOptions:
		# 	mapTypeIds: [google.maps.MapTypeId.ROADMAP, MAPTYPE_ID]
		# mapTypeId: MAPTYPE_ID
		disableDefaultUI: true
		mapTypeControl: true
		mapTypeControlOptions:
			style: google.maps.MapTypeControlStyle.DEFAULT
			mapTypeIds: [
				CUSTOM_MAPTYPE_ID
				google.maps.MapTypeId.HYBRID
			]
		
	map = new google.maps.Map document.getElementById(ID_MAP_CANVAS), mapOptions
	
	map.mapTypes.set CUSTOM_MAPTYPE_ID, customMapType
	map.setMapTypeId CUSTOM_MAPTYPE_ID
	
	# Place geopoints
	placeMapData()
	
	google.maps.event.addListener map, 'mouseout', ()->
		resetInfo()

google.maps.event.addDomListener(window, 'load', initMap);


reloadData = ()->
	console.log 'Reloading...'
	$iconLoading.toggle true
	$.ajax
		type: 'POST'
		url: '/map/reload'
		data: JSON.stringify {}
		contentType: 'x-www-form-urlencoded'
		success: (res) ->
			$iconLoading.toggle false
			if res.success
				geofences = res.body.geofences
				geopoints = res.body.geopoints
				placeMapData()
				console.log 'Reload success!'
			else
				console.log 'Error loading data: ' + res.body.error
				return
		error: () ->
			$iconLoading.toggle false
			console.log 'Error asking for data'
			return

setInterval ()->
	reloadData()
, 30000 #60000 = 1m
