/**
 *  Let There Be Light!
 *  Turn your lights on when an open/close sensor opens and off when the sensor closes.
 *
 *  Author: SmartThings
 */

def preferences()
{
  return [
		sections: [
			[
				title: "Turn outlet on/off...",
				input: [
					[
						name: "switch2",
						title: "Which?",
						type: "capability.switch",
						description: "Tap to set",
						multiple: false
					]
				]
			]
		]
	]
}

def installed()
{
    subscribe(switch2.switch)
}


def updated()
{
	unsubscribe()
    subscribe(switch2.switch)
	
}


def acsLogin(){
	
    state.apiKey = 'YOUR_KEY'
    
	log.debug "Attempting Appcelerator Cloud Services Login..."
	
	def successClosure = {response ->
    	state.sessionID = response?.data.meta.session_id
		log.debug "Login Success...Session ID: ${state.sessionID}"
		
	}
	
	def json = "{ 'login' : 'USERNAME','password' : 'PASSWORD' }"
	
	def params = [
		uri: "https://api.cloud.appcelerator.com/v1/users/login.json?key="+state.apiKey,
		success: successClosure,
		body: json
	]

	httpPostJson(params)
	
}

def ACSPush(message){
	
	def successClosure = { response ->
		log.debug response?.data.meta.code
	}
    
    def json = "{'payload':{'badge':0,'sound':'default','alert':'"+message+"'},'channel':'smartapp'}"
	
	def params = [
		uri: 'https://api.cloud.appcelerator.com/v1/push_notification/notify.json?key='+state.apiKey+'&_session_id='+state.sessionID,
		success: successClosure,
		body: json
	]
    
    log.info params
	
    httpPostJson(params)
}

def "switch"(evt){
	acsLogin()
    if (evt.value == "on") {
		log.debug "turning on switch"
    ACSPush("Your lights are on.")
	} else if (evt.value == "off") {
		log.debug "turning off switch"
		ACSPush("Your lights are off.")
	}
}
