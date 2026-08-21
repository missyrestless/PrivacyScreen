/*( Saucer v0.5 )*/


/*//-- Request Handler variables --//*/
list    gLstPag;    //-- List of known pages
list    gLst404Tim; //-- 404 timeout
list    gLst404Key; //-- 404 request key
list    gLst404Pag; //-- 404 page name (used for discovery only)
integer gIntLnk;    //-- link number to save on function calls


default{
	state_entry(){
		gIntLnk = llGetLinkNumber();
		llMessageLinked( LINK_SET, 418, "Saucer Start", NULL_KEY );
	}
	
	link_message( integer vIntSrc, integer vIntDta, string vStrDta, key vKeyDta ){
		if (vKeyDta){ //-- server traffic?
			if (418 == vIntDta && gIntLnk == vIntSrc){ //-- server request? // next line: Ignore Known Pages
				if (!~vIntDta = llListFindList( gLstPag, [vStrDta = llList2String( llParseStringKeepNulls( vStrDta, ["?"], [] ), 0 )] )){
					gLst404Key += [vKeyDta]; //-- Pending 404 key (used to detect lazy page additions or Send 404s)
					gLst404Pag += [vStrDta]; //-- Pending 404 name (used for lazy Know Page additions)
					gLst404Tim += [llGetUnixTime() + 2]; //-- Timeout value: this actually amount to a ~2.25sec timeout
					if (gLst404Tim == [""]){ //-- Only start timer for first pending 404, avoids bumping the timer forward.
						llSetTimerEvent( 0.75 ); //-- Fast to deal with fast pages requests
					}
				} //-- Next Line: Check for unadvertised responses for pending 404s
			}else if (~vIntSrc = llListFindList( gLst404Key, [vKeyDta] )){
				if (200 == vIntDta){ //-- auto discovery of  unadvertised pages
					gLstPag += [llList2String( gLst404Pag, vIntSrc )];
				}
				gLst404Tim = llDeleteSubList( gLst404Tim, vIntSrc, vIntSrc );
				gLst404Key = llDeleteSubList( gLst404Key, vIntSrc, vIntSrc );
				gLst404Pag = llDeleteSubList( gLst404Pag, vIntSrc, vIntSrc );
			}
		}else if (601 == (1 | vIntDta) && NULL_KEY == (string)vKeyDta){
			if (1 & vIntDta){ //-- 601 = add file (if NOT found)
				if (!~vIntDta = llListFindList( gLstPag, [vStrDta] )){
					gLstPag += [vStrDta];
				}
			}else{ //-- 600 remove file (only if found, avoids wrong index)
				if (~vIntDta = llListFindList( gLstPag, [vStrDta] )){
					gLstPag = llDeleteSubList( gLstPag, vIntDta, vIntDta );
				}
			}
		}
	}
	
	timer(){ //-- handle pending 404s
		if (gLst404Tim != []){ //-- Pending 404s?
			while (llList2Integer( gLst404Tim, 0 ) < llGetUnixTime()){ //-- Timeouts expired?
				llMessageLinked( llGetLinkNumber(), 404, "404 Not Found", llList2Key( gLst404Key, 0 ) );
				gLst404Tim = llDeleteSubList( gLst404Tim, 0, 0 ); //-- Send 404, Remove pending
				gLst404Key = llDeleteSubList( gLst404Key, 0, 0 );
				gLst404Pag = llDeleteSubList( gLst404Pag, 0, 0 );
				if (gLst404Tim == []){ //-- Pending Queue empty?
					llSetTimerEvent( 0.0 );
					return; //-- Stop timer, & exit
				}
			}
		}else{ //-- No Pending 404s, stop timer
			llSetTimerEvent( 0.0 );
		}
	}
}
/*//--                           License Text                           --//*/
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
