/*( Tea Strainer v0.5.1 )*/

integer gIntAct; //-- pre-declaration for speed
integer gIntCnt; //-- Allow visual tracking since last reset

//-- optimized for speed, NOT size

default {
	link_message( integer vIntSrc, integer vIntDta, string vStrDta, key vKeyDta ) {
		if (vKeyDta) {
			if (~gIntAct = llListFindList( [204, 202, 201, 200, 100, 403, 404, 418], [vIntDta] )) {
				if (4 & gIntAct) { if (2 & gIntAct) { if (1 & gIntAct) {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Server Query: 418 “" + llGetSubString( vStrDta, 0, 35 ) + llList2String( ["”…", "”"], llStringLength( vStrDta ) < 37 ) );
				}else {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 404 'Not Found'" );
				}}else if (1 & gIntAct) {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 403 'Forbidden'" );
				}else {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 100 'Continue'" );
				}}else if (2 & gIntAct) { if (1 & gIntAct) {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 200 'Success'" );
				}else {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 201 'Created'" );
				}}else if (1 & gIntAct) {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 202 'Accepted'" );
				}else {
					llOwnerSay( (string)(++gIntCnt) + ": ‘" + (string)vKeyDta + "’ Service Reply: 204 'No Content'" );
				}
			}else {
				llOwnerSay( "Received unknown message from link (" + (string)vIntSrc + ")“" +
				  llGetLinkName( vIntSrc ) +"”\n {(" + (string)vIntDta + "), “" + llGetSubString( vStrDta, 0, 35 ) +
				  llList2String( ["”…, ‘", "”, ‘"], llStringLength( vStrDta ) < 37 ) + (string)vKeyDta + "’}" );
			}
		}else if (NULL_KEY == (string)vKeyDta) {
			if (~gIntAct = llListFindList( [418, 600, 601], [vIntDta] )) {
				if (2 & gIntAct) { /*if (1 & gIntAct) {
					//-- unused
				}else*/ {
					llOwnerSay( (string)(++gIntCnt) + ": " + "File Service: 601 'File Added' “" + vStrDta + "”" );
				}}else if (1 & gIntAct) {
					llOwnerSay( (string)(++gIntCnt) + ": " + "File Service: 600 'File Removed' “" + vStrDta + "”" );
				}else {
					if ("Teacup URL changed" == vStrDta) {
						vStrDta += "”\n“ " + llList2String( llGetPrimitiveParams( [PRIM_TEXT] ), 0 ) + " ";
						gIntCnt = 0;
					}
					llOwnerSay( (string)(++gIntCnt) + ": " + "General Advertisement: “" + vStrDta + "”" );
				}
			}else {
				llOwnerSay( "Received unknown message from link (" + (string)vIntSrc + ")“" +
				  llGetLinkName( vIntSrc ) +"”\n{(" + (string)vIntDta + "), “" + llGetSubString( vStrDta, 0, 35 ) +
				  llList2String( ["”…, ‘", "”, ‘"], llStringLength( vStrDta ) < 37 ) + (string)vKeyDta + "’}" );
			}
		}else {
			llOwnerSay( "Received unknown message from link (" +
			  (string)vIntSrc + ")“" + llGetLinkName( vIntSrc ) +"”\n{(" + (string)vIntDta + "), “" +
			  llGetSubString( vStrDta, 0, 35 ) + llList2String( ["”…, ‘", "”, ‘"], llStringLength( vStrDta ) < 37 ) +
			  llGetSubString( vKeyDta, 0, 35 ) + llList2String( ["’…}", "’}"], llStringLength( vKeyDta ) < 37 ) );
		}
	}
}
/*//--                           License Text                           --//*/
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
