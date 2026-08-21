/*( Teacup Server v0.5 )*/


 /*//-- Teacup Boot Strap Variables --//*/
 //-- Server Default page start (always loads)
string  gStrTBS1xx = "data:text/html;charset:utf-8,<html>\n";
 //-- Head Section start: loads with URL_REQUEST_GRANTED
string  gStrTBS1a1 = "	<head>\n		<base href='";
 //-- Head Section end & Address intsertion point: loads with URL_REQUEST_GRANTED
string  gStrTBS1a2 = "'/>\n		<script type='text/javascript' defer='' src='teacup.js'></script>\n	</head>\n";
 //-- Server Default message (always loads)
string  gStrTBS2xx = "	<body>\n		<h1>Teacup Server</h1>\n		<hr/>\n		<h2>If you are reading this, the <em>server</em> is working</h2>\n";
 //-- Default Error message: loads with URL_REQUEST_GRANTED
string  gStrTBS2a1 = "		<h3>(But the File Service may not be)</h3>\n";
 //-- URL Failure MessageL included for URL_REQUEST_DENIED
string  gStrTBS2b1 = "		<h3>(But the region failed to provide a URL)</h3>\n";
 //-- Server Default Footer start (always loads)
string  gStrTBS3xx = "		<hr/>\n		<p>Teacup/Saucer v0.3<br/><a href='secondlife:///app/agent/";
 //-- Server Default Footer end & Contact Owner key insertion point (always loads)
string  gStrTBS4xx = "/about'>Contact Owner?</a></p>\n	</body>\n</html>";

 /*//-- Pending Request Variables --//*/
list    gLstPndKey; //-- Key queue (pages waiting to be served)
list    gLstPndTim; //-- Timeout Value queue (Request Timeout)
//-- These (hopefully) prevent multiple responses if SL sends a timeout.


default{
	state_entry(){ //-- Request URL on start up
		llRequestURL();
	}
	
	on_rez( integer vIntBgn ){ //-- Clear pending and request new URL on rez
		gLstPndKey = gLstPndTim = [];
		llRequestURL();
	}
	
	changed( integer vBitChg ){ //-- Clear pending and re-request URL on region change/restart
		if ((CHANGED_REGION_START | CHANGED_REGION) & vBitChg){
			gLstPndKey = gLstPndTim = []; //-- Consider sending custom 404's or 205's here instead
			llRequestURL();
		}
	}
	
	http_request( key vKeySrc, string vStrMth, string vStrBdy ){
		integer vIntMth = llListFindList( [URL_REQUEST_DENIED, URL_REQUEST_GRANTED, "POST", "GET"], [vStrMth] );
		if (4 & vIntMth){
			//-- trap unused here, check we hasve a valid non root file name on the next line
		}else if (2 & vIntMth){ if (vStrMth = llUnescapeURL( llDeleteSubString( llGetHTTPHeader( vKeySrc, "x-path-info" ), 0, 0 ) )){
			llMessageLinked( LINK_SET,
			                 418,
			                 vStrMth + "?" + llGetHTTPHeader( vKeySrc, "x-query-string" ) +
			                 "#ip=" + llGetHTTPHeader( vKeySrc, "x-remote-ip" ) + "&" + vStrBdy,
			                 vKeySrc );
			if (gLstPndTim == []){
				llSetTimerEvent( 3.0 );
			}
			gLstPndKey += [vKeySrc];
			gLstPndTim += [llGetUnixTime() + 20];
		}//-- can handle root requests here later if we want
		}else{ //-- URL request response: set hover text, push proper page format to prim face
			if (vIntMth || llList2String( llGetPrimitiveParams( [PRIM_TEXT] ), 0 ) != "No URL"){
				llSetPrimitiveParams( [PRIM_TEXT, llList2String( ["No URL", (vStrBdy += "/")], vIntMth ), <(float)(!vIntMth), 0.5, 0.5>, 0.0] );
				vStrBdy = gStrTBS1xx + llList2String( ["", gStrTBS1a1 + vStrBdy + gStrTBS1a2], vIntMth ) + gStrTBS2xx +
				  llList2String( [gStrTBS2a1, gStrTBS2a1], vIntMth ) + gStrTBS3xx + (string)llGetOwner() + gStrTBS4xx;
				llSetPrimMediaParams( 0, [PRIM_MEDIA_HOME_URL, vStrBdy, PRIM_MEDIA_CURRENT_URL, vStrBdy] );
				llMessageLinked( LINK_SET, 418, "Teacup URL changed", NULL_KEY );
			} //-- Next Line: abuse Sensor Repeat to retry on no URL in 5 mins
			llSensorRepeat( "", llGetKey(), AGENT, 0.0001 * !vIntMth, PI, 300.0 * !vIntMth );
		}
	}
	
	link_message( integer vIntSrc, integer vIntDta, string vStrDta, key vKeyDta ){
		if (~vIntSrc = llListFindList( [200, 201, 202, 204, 403, 404], [vIntDta] )){ //-- valid return code?
			if (~vIntSrc = llListFindList( gLstPndKey, [vKeyDta] )){ //-- request still pending?
				llHTTPResponse( vKeyDta, vIntDta, vStrDta ); //-- Serve request & remove from pending queue
				gLstPndKey = llDeleteSubList( gLstPndKey, vIntSrc, vIntSrc );
				gLstPndTim = llDeleteSubList( gLstPndTim, vIntSrc, vIntSrc );
			}
		}
	}
	
	timer(){ //-- Optimally, runs once on an empty list for 3sec worth requests
		if (gLstPndTim != []){ //-- Pending requests?
			while (llList2Integer( gLstPndTim, 0 ) < llGetUnixTime()){ //-- are any expired?
				gLstPndTim = llDeleteSubList( gLstPndTim, 0, 0 ); //-- remove expired
				gLstPndKey = llDeleteSubList( gLstPndKey, 0, 0 );
				if (gLstPndTim == []){ //-- Pending Queue empty?
					llSetTimerEvent( 0.0 ); //-- Stop timer, and exit
					return;
				}
			}
		}else{ //-- No pending requests, turn off the timer
			llSetTimerEvent( 0.0 );
		}
	}
	
	sensor( integer vIntNul ){
		//-- Dummy Sensor event required by SCR-53
	}
	
	no_sensor(){ //-- URL re-request 5 mins after failure
		llSensorRemove();
		llRequestURL();
	}
}
/*//--                           License Text                           --//*/
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
