/*( Red Tea v0.5.1 )*/
 
//-- Master Handling lists
list    gLstNom;
list    gLstTxt;
 
//-- These track memory while loading
integer gIntCap;
integer gIntBfr;
 
//-- these handle the notecard loading
key     gKeyQry;
string  gStrNcd;
integer gIntNcd;
string  gStrTmp;

default {
  state_entry() {
     //-- grab all possible notecard names
    if (gIntCap = llGetInventoryNumber( INVENTORY_NOTECARD )) {
      llWhisper( 0, "Attempting to load " + (string)gIntCap + " notecards" );
      do {
        gLstNom += [llGetInventoryName( INVENTORY_NOTECARD, gIntNcd )];
      } while (++gIntNcd < gIntCap);
       //-- work on the firs one.
      gKeyQry = llGetNotecardLine( gStrNcd = llList2String( gLstNom, 0 ), gIntNcd = 0 );
      gIntCap = llGetFreeMemory();
    } else {
      llWhisper( 0, "No content to load" );
    }
  }
  
  changed( integer vBitChg ) {
    if (CHANGED_INVENTORY & vBitChg) {
       //-- when inventory changes, only restart if the notecard count changed
      if (llGetInventoryNumber( INVENTORY_NOTECARD ) != (gLstNom != [])) {
        llSetTimerEvent( 5.0 );
      }
    }
  }
  
  timer() {
    llResetScript();
  }
  
  dataserver( key vKeyQID, string vStrDta ) {
    if (gKeyQry == vKeyQID) { //-- is this our dataserver event?
      if (EOF == vStrDta) { //-- did we finish the notecard?
        if (~llSubStringIndex( gStrNcd, ".tsp" )) { //-- is this a html page?
          gStrTmp = "v0='" + gStrTmp + "';"; //-- wrap it
        }
        gLstTxt += [(gStrTmp = "") + gStrTmp]; //-- save it
        llWhisper( 0, gStrNcd + " successfully loaded");
        llMessageLinked( LINK_SET, 601, gStrNcd, NULL_KEY ); //-- saucer compatibility
        if ((integer)(vStrDta = (string)(gIntCap - llGetFreeMemory())) > gIntBfr) {
          gIntBfr = (integer)vStrDta; //-- adjust buffer if needed
        } //-- test if we have more cards to read and room to spare
        if ((gIntNcd = -~llListFindList( gLstNom, [gStrNcd] )) < (gLstNom != []) && (gIntCap = llGetFreeMemory()) > gIntBfr) {
          gKeyQry = llGetNotecardLine( gStrNcd = llList2String( gLstNom, gIntNcd ), gIntNcd = 0 ); //-- get next card
        } else { //-- out of cards or space
          gStrTmp = gKeyQry = ""; //-- clear vars
           //-- save totals and set conditional failure message
          if ((gIntCap = (gLstNom != [])) > (gIntNcd = (gLstTxt != []))) {
            gStrNcd = "\nFailed to read " + gStrNcd; 
          } else {
            gStrNcd = gStrTmp;
          } //-- report load
          llWhisper( 0, "Loaded " + (string)gIntNcd + " of " + (string)gIntCap + " pages" + (gStrNcd = "") +
                        gStrNcd + "\n~" + (string)(llGetFreeMemory() - gIntBfr) + " bytes free"  );
        }
      } else { //-- notecard read
        if (~llSubStringIndex( gStrNcd, ".tsp" )) { //-- is this a html page?
           //-- tweak for javascript wrapper compatibility
          vStrDta = llDumpList2String( llParseStringKeepNulls( vStrDta, ["\\"], [] ), "\\\\" ); //-- "
          vStrDta = llDumpList2String( llParseStringKeepNulls( vStrDta, ["'"], [] ), "\\'" ) + "\\n";
        } else {
          vStrDta += "\n";
        }
        gStrTmp += vStrDta; //-- accumulate to variable
        if ((integer)(vStrDta = (string)(gIntCap - llGetFreeMemory())) > gIntBfr) {
          gIntBfr = (integer)vStrDta; //-- adjust buffer if needed
        }
        if ((gIntCap >> 1) > gIntBfr) { //-- test free space against buffer
          gKeyQry = llGetNotecardLine( gStrNcd, ++gIntNcd ); //-- get next line
        } else { //-- our saftey cap was exceeded, stop and report what we have
          gLstNom = llDeleteSubList( gLstNom, gIntNcd, -1 );
          gIntCap = (gLstNom != []);
          gIntNcd = (gLstTxt != []);
          gStrTmp = gKeyQry = "";
          llWhisper( 0, "Loaded " + (string)gIntNcd + " of " + (string)gIntCap + " page(s)\nFailed while reading " +
                        gStrNcd + "\n~" + (string)(llGetFreeMemory() - gIntBfr) + " bytes free"  );
        }
      }
    }
  }
  
  link_message( integer vIntSrc, integer vIntDta, string vStrDta, key vKeyDta ) {
    if (vKeyDta) { //-- valid key?
      if (418 == vIntDta) { //-- server request?
        if (~vIntDta = llListFindList( gLstNom, [llList2String( llParseStringKeepNulls( vStrDta, [], ["?", "#"] ), 0 )] )) { //-- do we have that?
          llMessageLinked( vIntSrc, 200, llList2String( gLstTxt, vIntDta ), vKeyDta );
        }
      }
    } //-- fast service, no need to add saucer start compatibility
  }
}
/*//--                           License Text                           --//*/
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
