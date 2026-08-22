/*( Region Stats )*/

string  gStrNom = "Region Stats.tsp"; //-- file name that we serve data to
//-- we insert the page name & request key later for the refresh to override same page cahing in the internal browser
string  gStrPg0 = "v0='<script>RS=setTimeout(\"u1(\\'";
string  gStrPg1 = "\\')\", 60000 );</script>\\n<p><a href=\"index.tsp\" onClick=\"clearTimeout(RS);\">Return to index</a>?</p>\\n<table>\\n";
string  gStrPg2 = "</table>';"; //-- page footer

string  gStrNfo; //-- stores static Region information
integer gIntFlg; //-- the current region flags
string  gStrFlg; //-- stores Region flags (updated as needed only)
string  gStrTod; //-- Stores Region Time of Day (updates live if Fixed Sun == false)

key     gKeyQry; //-- Dataserver Query key
integer gBooRdy; //-- Controls availability advertisement

uGetTod( vector vPosSun ) { //-- grabs Region apparent Time of Day (slightly inaccurate)
	vPosSun = llVecNorm( <vPosSun.x, 0.0, vPosSun.z> );
	integer vIntTod = (integer)(86400.0 - (llAtan2( vPosSun.x, vPosSun.z ) * RAD_TO_DEG + 180) * 240.0);
	gStrTod = (string)(vIntTod / 3600) + ":" + llGetSubString( "0" + (string)(vIntTod % 3600 / 60), -2, -1 ) +
		":" + llGetSubString( "0" + (string)(vIntTod % 60), -2, -1 ) + "";
}

default {
	state_entry() { //-- make the page seem unavailable while we refresh our static data
		llMessageLinked( LINK_SET, 600, gStrNom, NULL_KEY );
		gStrNfo = //-- Start building static info
		  "<tr><td><span style=\"font-weight: bold;\">Pre-calculated Data</span></td></tr>\\n<tr><td>Region Name:</td><td>" +
		  llGetRegionName() + "</td></tr>\\n";
		uGetTod( llGetSunDirection() ); //-- set once to make logic faster later
		gKeyQry = llRequestSimulatorData( llGetRegionName(), DATA_SIM_RATING );
	}
	
	dataserver( key vKeyQID, string vStrDta ) {
		if (gKeyQry == vKeyQID) { //-- continue building static info
			gStrNfo += "<tr><td>Region Rating:</td><td>" + //-- this is one way to get unknown ratings noticed =X
			  llList2String( ["General", "Moderate", "Adult", "XXX Pr0nland"],
			                 llListFindList( ["PG", "MATURE", "ADULT", "UNKNOWN"], [vStrDta] ) ) +
			  "</td></tr>\\n<tr><td>Region Location:</td><td>(";
			vector vPosTmp = llGetRegionCorner();
			gStrNfo += (string)((integer)vPosTmp.x) + ", " +
			  (string)((integer)vPosTmp.y) + ")</td></tr>\\n<tr><td>Server Name:</td><td>" +
			  llGetSimulatorHostname() + "</td></tr>\\n<tr><td>Server Channel:</td><td>" +
			  llGetEnv( "sim_channel" ) + "</td></tr>\\n<tr><td>Server Version:</td><td>";
			list vLstTmp = llParseString2List( llGetEnv( "sim_version" ), ["."], [] );
			gStrNfo += //-- version number contains build date, sneaky huh?
			  llDumpList2String( vLstTmp, "." ) + "</td></tr>\\n<tr><td>Server Build Date:</td><td>" +
			  llList2String( ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
			                 ~-llList2Integer( vLstTmp, 1 ) ) +
			  " " + llList2String( vLstTmp, 2 ) + ", 20" + llList2String( vLstTmp, 0 ) + "</td></tr>\\n";
			gBooRdy = TRUE; //-- this variable is only used to readvertise to Saucer when it starts
			llMessageLinked( LINK_SET, 601, gStrNom, NULL_KEY );
		}
	}
	
	link_message( integer vIntSrc, integer vIntDta, string vStrDta, key vKeyDta ) {
		if (418 == vIntDta) {
			if (vKeyDta) {
				if (gStrNom == llList2String( llParseStringKeepNulls( vStrDta, ["?"], [] ), 0 )) {
					if (gIntFlg != vIntDta = llGetRegionFlags()) {
						gIntFlg = vIntDta; //-- only (re)built if flags change or at first request
						list vLstFlg = ["Y", "N"]; //-- need to check this is better for mono lists than inline
						gStrFlg = "<tr><td><span style=\"font-weight:bold;\">Region Flags</span></td></tr>\\n<tr><td>Damage Enabled?</td><td>" +
						llList2String( vLstFlg, !(0x00000001 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Allow Landmark?</td><td>" +
						llList2String( vLstFlg, !(0x00000002 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Allow Set Home?</td><td>" +
						llList2String( vLstFlg, !(0x00000004 & gIntFlg) ) +
						/*//-- I don't think this is used
						"</td></tr>\\n<tr><td>†Reset Home On Teleport?</td><td>" +
						llList2String( vLstFlg, !(0x00000008 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>Fixed Sun?</td><td>" +
						llList2String( vLstFlg, !(0x00000010 & gIntFlg) ) +
						/*//-- Unused, taxes were abolished for SL ages ago
						"</td></tr>\\n<tr><td>†Tax Free?</td><td>" +
						llList2String( vLstFlg, !(0x00000020 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>Block Terraform?</td><td>" +
						llList2String( vLstFlg, !(0x00000040 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Block Land Resell?</td><td>" +
						llList2String( vLstFlg, !(0x00000080 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>Is Sandbox?</td><td>" +
						llList2String( vLstFlg, !(0x00000100 & gIntFlg) ) +
						/*//-- I don't think any of these are used
						"</td></tr>\\n<tr><td>‡Null Layer?</td><td>" +
						llList2String( vLstFlg, !(0x00000200 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>‡Allow Land Xfer?</td><td>" +
						llList2String( vLstFlg, !(0x00000400 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>‡Skip Update Interest List?</td><td>" +
						llList2String( vLstFlg, !(0x00000800 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>Disable Collisions?</td><td>" +
						llList2String( vLstFlg, !(0x00001000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Skip Scripts?</td><td>" +
						llList2String( vLstFlg, !(0x00002000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>Disable Physics?</td><td>" +
						llList2String( vLstFlg, !(0x00004000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Externally Visible?</td><td>" +
						llList2String( vLstFlg, !(0x00008000 & gIntFlg) ) +
						/*//-- Encroachment code isn't used(yet), Dwell was removed ages ago
						"</td></tr>\\n<tr><td>†Allow Return Encroaching<td>?</td><td>" +
						llList2String( vLstFlg, !(0x00010000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Allow Return Enchroching(Estate)?</td><td>" +
						llList2String( vLstFlg, !(0x00020000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Block Dwell?</td><td>" +
						llList2String( vLstFlg, !(0x00040000 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>Block Fly?</td><td>" +
						llList2String( vLstFlg, !(0x00080000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>Allow Direct TP?</td><td>" +
						llList2String( vLstFlg, !(0x00100000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Skip Scripts(Estate)?</td><td>" +
						llList2String( vLstFlg, !(0x00200000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>Restrict Push?</td><td>" +
						llList2String( vLstFlg, !(0x00400000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Deny Anonymous?</td><td>" +
						llList2String( vLstFlg, !(0x00800000 & gIntFlg) ) +
						/*//-- I don't think these are used anymore, used to be for OI?
						"</td></tr>\\n<tr><td>‡Deny Identified?</td><td>" +
						llList2String( vLstFlg, !(0x01000000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>‡Deny Transacted?</td><td>" +
						llList2String( vLstFlg, !(0x02000000 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>†Allow Parcel Changes?</td><td>" +
						llList2String( vLstFlg, !(0x04000000 & gIntFlg) ) +
						/*//-- Prtty sure this is disabled
						"</td></tr>\\n<tr><td>‡Abuse Email 2 Estate Owner?</td><td>" +
						llList2String( vLstFlg, !(0x08000000 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td>†Allow Voice?</td><td>" +
						llList2String( vLstFlg, !(0x10000000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Block Parcel Search?</td><td>" +
						llList2String( vLstFlg, !(0x20000000 & gIntFlg) ) +
						"</td></tr>\\n<tr><td>†Deny Age unVerified?</td><td>" +
						llList2String( vLstFlg, !(0x40000000 & gIntFlg) ) +
						/*//-- Pretty sure this is disabled as well since MONO went mainstream.
						"</td></tr>\\n<tr><td>‡Skip Scripts(MONO)?</td><td>" +
						llList2String( vLstFlg, !(0x80000000 & gIntFlg) ) +
						*/
						"</td></tr>\\n<tr><td><br>†=Does not have an LSL constant<br>‡=No longer exists in source code</td></tr>\\n";
					}
					if (~gIntFlg & 0x00000010) { //-- don't update for fixed sun
						uGetTod( llGetSunDirection() );
					}
					llMessageLinked( vIntSrc,
					                 201, //-- Next Line: key insertion lets us override internal browser page caching for live refresh
					                 gStrPg0 + gStrNom + "?" + (string)vKeyDta + gStrPg1 + gStrNfo + 
					                 "<tr><td><span style=\"font-weight: bold;\">Live Data</span></td></tr>\\n<tr><td>Region Tod:</td><td>" +
					                 gStrTod + " rST (24hr)</td></tr>\\n<tr><td>Region FPS:</td><td>" +
					                 (string)llGetRegionFPS() + "</td></tr>\\n<tr><td>Time Dilation:</td><td>" +
					                 (string)llGetRegionTimeDilation() + "</td></tr>\\n<tr><td>Agent Count:</td><td>" +
					                 (string)llGetRegionAgentCount() + "</td></tr>\\n<tr><td>Shared Borders:</td><td>" +
					                 (string)(!llEdgeOfWorld( <128.0, 128.0, 128.0>, < 0.0,  1.0, 0.0> ) + 
					                 !llEdgeOfWorld( <128.0, 128.0, 128.0>, < 1.0,  0.0, 0.0> ) +
					                 !llEdgeOfWorld( <128.0, 128.0, 128.0>, < 0.0, -1.0, 0.0> ) + 
					                 !llEdgeOfWorld( <128.0, 128.0, 128.0>, <-1.0,  0.0, 0.0> )) +
					                 "</td></tr>\\n" + gStrFlg + gStrPg2,
					                 vKeyDta );
				}
			} else if (NULL_KEY == vKeyDta && "" == vStrDta && gBooRdy) {
				//-- Saucer stared, let tell it we have a page. Realistically unneccessary
				llMessageLinked( vIntSrc, 601, gStrNom, NULL_KEY );
			} //-- out page actualy serves in under a sec even on first request, but I wanted to demo the logic
		}
	}
	
	changed( integer vBitChg ) {
		if ((CHANGED_REGION | CHANGED_REGION_START) & vBitChg) {
			llResetScript(); //-- Regions changes or Restarts may have new static info
		}
	}
	
	on_rez( integer vIntBgn ) {
		llResetScript(); //-- Make sure static info is releveant to current region
	}
}
/*//--                           License Text                           --//*/
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
