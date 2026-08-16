///////////////////////////////////////////////////////////////////////////////////
//     Toggle Transparency & Phantom with Touch or Message on Listen Channel     //
//                                                                               //
// Message or Touch by owner of object toggles Face 0 transparency               //
// Listens on channel 0 for trigger messages to shield or become invisible       //
// Messages other objects in region with same owner to trigger toggle command    //
// When the shield is up the prim is solid, when invisible the prim is phantom   //
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////
// Copyright (c) 2026 Truth & Beauty Lab          //
// License: GPLv3                                 //
// All rights reserved.                           //
//                                                //
// Author: Missy Restless missyrestless@gmail.com //
////////////////////////////////////////////////////

////////////////////////////////////////////////////
//            Modification History                //
//            --------------------                //
// 2026-Aug-10 Created                            //
// 2026-Aug-11 Gesture controls                   //
// 2026-Aug-12 Multiple textured faces            //
// 2026-Aug-13 Add timers to lock state changes   //
// 2026-Aug-16 Add dialog menu management         //
//                                                //
////////////////////////////////////////////////////

string  VERSION = "1.1.0";
integer ALL     = TRUE;      // Set to TRUE to effect all shields, FALSE for single shield
integer DEBUG   = FALSE;     // Set to TRUE for debug messages to owner, FALSE to disable
integer FLASH   = FALSE;     // Set to TRUE to flash when shield activates, FALSE to disable
integer SOLID   = TRUE;      // Set to FALSE for always phantom shields, TRUE phantom when invisible
integer TOUCH   = FALSE;     // Set to TRUE to enable touch toggles, FALSE to disable
integer listenerID;          // Not yet used
integer objListenID;         // Not yet used
integer dialogHandle;        // Dialog Menu listener handle, channel, boolean
integer dialogChannel;
integer pageNumber    = 1;
integer listenChannel = 0;   // Channel for chat and gestures
integer objChannel;          // Channel for communication between screens, based on owner
integer shieldStatus;        // TRUE if screen active, FALSE if screen is transparent
integer total_faces;         // Number of textured faces
integer rcv_lower;           // Boolean indicating recieved lower screen message
integer rcv_raise;           // Boolean indicating recieved raise screen message
integer rcv_state;           // Boolean indicating recieved state message

integer defaultState = TRUE;
key     owner = NULL_KEY;
list    faces = [];          // Faces with screen texture, all other faces will be transparent
float   cloakSpeed = 0.1;
vector  prim_size;

// Linkset Data Keys
//
// Owner only linkset data key
string  OWNER_O_LSD_KEY  = "owner_only";
// Online texture linkset data key
string  ON_TXT_LSD_KEY   = "online_texture";
// Offline texture linkset data key
string  OFF_TXT_LSD_KEY  = "offline_texture";
// Transparency linkset data key
string  OPAQUE_LSD_KEY   = "is_transparent";

integer isTransparent  = FALSE;
string  OnlineTexture  = "Mosaic-Online";
string  OfflineTexture = "Mosaic-Offline";

integer ownerOnly = TRUE;

setFacesAlpha(float trans) {
    integer i;
    for (i = 0; i < total_faces; ++i)
    {
        llSetAlpha(trans, llList2Integer(faces, i));
    }
}

lowerShield() {
    float alpha = 1.0;
    if (DEBUG) llOwnerSay("Lowering shield");
    while(alpha > 0.0) {
        alpha -= 0.1;
        setFacesAlpha(alpha);
        llSleep(cloakSpeed);
    }
    llSetAlpha(0.0, ALL_SIDES);
    llSetStatus(STATUS_PHANTOM, TRUE);
    shieldStatus = FALSE;
    llSetTimerEvent(5.0);
}

raiseShield() {
    if (DEBUG) llOwnerSay("Raising shield");
    float alpha = 0.0;
    integer count = 0;

    if (FLASH) {
        while (count < 4) {
            count += 1;
            if (alpha == 0.0) {
                alpha = 1.0;
            } else {
                alpha = 0.0;
            }
            llSetAlpha(alpha, ALL_SIDES);
            llSleep(1.0);
        }
    }
    alpha = 0.0;
    llSetAlpha(alpha, ALL_SIDES);
    while (alpha < 1.0) {
        alpha += 0.1;
        setFacesAlpha(alpha);
        llSleep(cloakSpeed);
    }
    if (SOLID) {
        llSetStatus(STATUS_PHANTOM, FALSE);
    } else {
        llSetStatus(STATUS_PHANTOM, TRUE);
    }
    shieldStatus = TRUE;
    llSetTimerEvent(5.0);
}

string getShieldSlurl() {
    vector currentPos = llGetPos();
    string regionName = llGetRegionName();

    // Round coordinates to whole integers
    integer x = (integer)currentPos.x;
    integer y = (integer)currentPos.y;
    integer z = (integer)currentPos.z;
    string coords = (string)x + "/" + (string)y + "/" + (string)z;

    // Return the constructed Slurl, escape region name as it may have spaces
    return "https://maps.secondlife.com/secondlife/" + llEscapeURL(regionName) + "/" + coords;
}

stateShield() {
    string prefix = "Truth & Beauty Privacy Shield version " + VERSION;
    string slurl = getShieldSlurl();

    string location = " at " + slurl;
    if (shieldStatus == TRUE) {
        llOwnerSay(prefix + location + " is VISIBLE and SOLID");
    } else {
        llOwnerSay(prefix + location + " is TRANSPARENT and PHANTOM");
    }
    llSetTimerEvent(5.0);
}

integer num_Textures(string prefix) {
    integer num_textures = 0;
    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);

    integer i;
    integer position;
    string texture_name;
    for (i = 0; i < count; ++i) {
        texture_name = llGetInventoryName(INVENTORY_TEXTURE, i);
        position = llSubStringIndex(texture_name, prefix);
        if (position != -1) {
            num_textures += 1;
        }
    }
    return num_textures;
}

list get_Textures(string prefix) {
    list texture_list = [];
    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);

    // Populate list (Dialogs only show up to 12 buttons at once)
    integer i;
    integer position;
    string texture_name;
    for (i = 0; i < count; ++i) {
        texture_name = llGetInventoryName(INVENTORY_TEXTURE, i);
        position = llSubStringIndex(texture_name, prefix);
        if (position != -1) {
            texture_list += [texture_name];
        }
    }
    return texture_list;
}

list arrange(list l) {
    list outl = [];
    integer n = llGetListLength(l);
    do {
        if (n < 3) return outl + l;
        n = n - 3;
        outl = outl + llList2List(l, -3, -1);
        if (n == 0) return outl;
        l = llList2List(l, 0, -4);
    } while (TRUE);
    return [];
}

displayMainMenu() {
    llListenRemove(dialogHandle);
    dialogHandle = llListen(dialogChannel, "", owner, "");
    list main_menu = [];
    string menuMessage;

    menuMessage = "\nTruth & Beauty Privacy Shield " + VERSION;
    if (ALL) {
        menuMessage += "\nMenu actions effect all shields in region\n";
        menuMessage += "\nSINGLE = Menu actions effect only this shield";
    } else {
        menuMessage += "\nMenu actions effect only this shield\n";
        menuMessage += "\nALL = Menu actions effect all shields in region";
    }
    if (FLASH) {
        menuMessage += "\nNO FLASH = Do not flash when activating shield";
    } else {
        menuMessage += "\nFLASH = Flash 3 times when activating shield";
    }
    if (SOLID) {
        menuMessage += "\nPHANTOM = Shields always phantom";
    } else {
        menuMessage += "\nSOLID = Active shields are solid";
    }
    if (TOUCH) {
        menuMessage += "\nTOUCH OFF = Touch opens dialog menu";
    } else {
        menuMessage += "\nTOUCH ON = Touch to raise/lower shields";
    }
    if (shieldStatus == TRUE) {
        menuMessage += "\nShields are UP";
        main_menu = ["DOWN", "INFO", "SIZE"];
    } else {
        menuMessage += "\nShields are DOWN";
        main_menu = ["UP", "INFO", "SIZE"];
    }
    if (ALL) {
        main_menu += ["SINGLE"];
    } else {
        main_menu += ["ALL"];
    }
    if (FLASH) {
        main_menu += ["NO FLASH"];
    } else {
        main_menu += ["FLASH"];
    }
    if (SOLID) {
        main_menu += ["PHANTOM"];
    } else {
        main_menu += ["SOLID"];
    }
    if (TOUCH) {
        main_menu += ["TOUCH OFF"];
    } else {
        main_menu += ["TOUCH ON"];
    }
    main_menu += ["EXIT"];
    ShowMenu(menuMessage, main_menu);
}

displaySizeMenu() {
    llListenRemove(dialogHandle);
    dialogHandle = llListen(dialogChannel, "", owner, "");
    list size_menu = [];
    string menuMessage;

    menuMessage = "\nResize the Truth & Beauty Privacy Shields";
    menuMessage += "\nCurrent shield size:";
    menuMessage += "\n\tX: " + (string) ( prim_size.x );
    menuMessage += "\n\tY: " + (string) ( prim_size.y );
    menuMessage += "\n\tZ: " + (string) ( prim_size.z );
    size_menu = ["24x12", "32x16", "40x20", "48x24", "56x28", "64x32"];
    size_menu += ["BACK", "EXIT"];
    ShowMenu(menuMessage, size_menu);
}

// Show the specific menu page
// Pass in the full menu list
ShowMenu(string msg, list fm) {
    integer list_length = llGetListLength(fm);
    if (list_length > 12) {
        integer totalPages = (list_length / 10) + (list_length % 10 != 0);

        // Safety check: bound page numbers
        if (pageNumber < 1) pageNumber = 1;
        if (pageNumber > totalPages) pageNumber = totalPages;

        // Calculate slice indices
        integer start = (pageNumber - 1) * 10;
        integer end = start + 9;

        // Grab the 10 (or fewer) items for this page
        list displayList = llList2List(fm, start, end);

        // Add navigation buttons to the bottom of the list
        if (totalPages > 1) {
            if (pageNumber > 1) displayList += ["<<< Back"];
            if (pageNumber < totalPages) displayList += ["Next >>>"];
        }

        // Send the dialog page
        llDialog(owner, msg + " (Page " + (string)pageNumber + " of " +
                (string)totalPages + "):", arrange(displayList), dialogChannel);
    } else {
        // Send the dialog
        llDialog(owner, msg, arrange(fm), dialogChannel);
    }
    llSetTimerEvent(60);   // If no response in time, return to previous state
}

// Truncates floating point representation to a single decimal digit
string FormatFloat(float num) {
    string ret;
    integer scale;

    scale = (integer)(num * 10);
    ret = (string)scale;
    integer length = llStringLength(ret);

    // Safety check for strings that are too short
    if (length < 2) return ret;

    // Split the string: everything up to the last char + "." + the last char
    return llGetSubString(ret, 0, length - 2) + "." + llGetSubString(ret, -1, -1);
}

string stripTrailingZeros(string str) {
    // Only proceed if there is a decimal point to avoid mangling whole numbers like "100"
    if (llSubStringIndex(str, ".") != -1) {
        while (llGetSubString(str, -1, -1) == "0") {
            str = llDeleteSubString(str, -1, -1);
        }
        // Optional: Remove the trailing decimal point if it's now the last character
        if (llGetSubString(str, -1, -1) == ".") {
            str = llDeleteSubString(str, -1, -1);
        }
    }
    return str;
}

// Writes the provided key/value pair to the prim's linkset datastore
integer linksetDataWrite(key id, string lsdKey, string value, integer link, string cfg) {
    string val = llStringTrim(value, STRING_TRIM);
    integer returnCode = llLinksetDataWrite(lsdKey, val);
    if (returnCode == LINKSETDATA_OK) {
        llMessageLinked(LINK_THIS, link, val, "");
        llRegionSayTo(id, 0, "[Privacy Shield] " + cfg + " saved.");
    } else if (returnCode == LINKSETDATA_NOUPDATE) {
        llMessageLinked(LINK_THIS, link, val, "");
        llRegionSayTo(id, 0, "[Privacy Shield] " + cfg + " already stored and is identical.");
    } else {
        llRegionSayTo(id, 0, "[Privacy Shield] " + cfg + " save failed (code " + (string)returnCode + ").");
    }
    return returnCode;
}

default {
    state_entry() {
        string currentTex;
        string DEFAULT_PLYWOOD     = "89556747-24cb-43ed-920b-47caed15465f";
        string BLANK               = "5b53359e-59dd-d8a2-04c3-9e65134da47a";
        string TTRANSPARENT        = "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903";
        string WHITE_TEXTURE       = "5748decc-f629-461c-9a36-a35a221fe21f";

        defaultState = TRUE;
        if (llGetAlpha(ALL_SIDES) > 0.0) {
            shieldStatus = TRUE;
        } else {
            shieldStatus = FALSE;
        }

        integer numOfSides = llGetNumberOfSides();
        integer i;
        // Find which faces are textured with non-default textures
        for (i = 0; i < numOfSides; ++i) {
            currentTex = llGetTexture(i);
            if ((currentTex != DEFAULT_PLYWOOD) &&
                (currentTex != TTRANSPARENT) &&
                (currentTex != BLANK) &&
                (currentTex != WHITE_TEXTURE) &&
                (currentTex != "*Default Transparent Texture") &&
                (currentTex != NULL_KEY)) {
                if (DEBUG) llOwnerSay("Adding textured face number: " + (string)i);
                faces += i;
            } else {
                if (DEBUG) {
                    llOwnerSay("Transparent face number: " + (string)i);
                    if (currentTex == NULL_KEY) {
                        llOwnerSay("Current texture: NO PRIVILEGE");
                    } else {
                        llOwnerSay("Current texture: " + currentTex);
                    }
                }
            }
        }

        total_faces = llGetListLength(faces);
        owner       = llGetOwner();
        // Compute a large negative channel number based on the object owner
        // All screens owned by the same owner will use the same channel
        objChannel = 0x80000000 | (integer) ( "0x" + (string) owner );
        if (DEBUG) llOwnerSay("Computed owner object channel: " + (string)objChannel);
        listenerID = llListen(listenChannel, "", owner, "");
        objListenID = llListen(objChannel, "", NULL_KEY, "");
        // Compute a negative communications channel based on prim UUID
        dialogChannel = 0x80000000 | (integer) ( "0x" + (string) llGetKey() );
        // Alternatively, generate a negative non-zero number from the last 7 digits of the prim UUID
        // dialogChannel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    }

    listen(integer channel, string name, key id, string message) {
        string cmd = llToLower(message);
        if (channel == listenChannel) {
            if (DEBUG) llOwnerSay("Heard in default state on chat/gesture listen channel: " + message);
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Down from default state");
                llRegionSay(objChannel, "Shields Down");
                lowerShield();
                state cloaked;
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Up from default state");
                llRegionSay(objChannel, "Shields Up");
                raiseShield();
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Info from default state");
                llRegionSay(objChannel, "Shields Info");
                stateShield();
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
            if (DEBUG) llOwnerSay("Heard in default state on inter-object listen channel: " + message);
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                lowerShield();
                state cloaked;
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                raiseShield();
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                stateShield();
            } else if (cmd == "flash off") {
                FLASH = FALSE;
            } else if (cmd == "flash on") {
                FLASH = TRUE;
            } else if (cmd == "phantom") {
                SOLID = FALSE;
            } else if (cmd == "solid") {
                SOLID = TRUE;
            } else if (cmd == "touch off") {
                TOUCH = FALSE;
            } else if (cmd == "touch on") {
                TOUCH = TRUE;
            }
        }
    }

    timer()
    {
        rcv_lower = FALSE;
        rcv_raise = FALSE;
        rcv_state = FALSE;
        llSetTimerEvent(0.0);
    }

    touch_start(integer num_detected) {
        // Ensure only the owner triggers the timer start check
        if (llDetectedKey(0) == owner) {
            llResetTime(); // Starts tracking duration
        }
    }

    touch_end(integer num_detected) {
        if (llDetectedKey(0) == owner) {
            float holdTime = llGetTime();

            if (TOUCH) {
                if (holdTime >= 1.0) {
                    // Long press for dialog menu
                    // Handle dialog menu in its own state
                    state menu;
                } else {
                    // Send the message to other objects in region with same owner listening on this channel
                    if (DEBUG) llOwnerSay("Sending Shields Down from default state touch");
                    llRegionSay(objChannel, "Shields Down");
                    lowerShield();
                    state cloaked;
                }
            } else {
                // If shield touch is disabled, display dialog menu on clicks as well
                state menu;
            }
        }
    }

    on_rez(integer num) {
        llResetScript();
        raiseShield();
        string slurl = getShieldSlurl();
        llOwnerSay("The Truth & Beauty Privacy Shield located at " + slurl + " is now active.");
        llOwnerSay("Activate the 'Shields Up', 'Shields Down', and 'Shields Info' gestures in your inventory");
        llOwnerSay("Once activated, saying '/up' in public chat will enable all sheilds you own in this region");
        llOwnerSay("Saying '/down' will disable the shields and make them phantom");
        llOwnerSay("Saying '/info' will report their status, version, and locations");
        llOwnerSay("Privacy Shield updates are free for life and will be available at:");
        llOwnerSay("    https://github.com/missyrestless/PrivacyShield/releases");
        llOwnerSay("The latest Truth & Beauty Privacy Shield documentation can be found at:");
        llOwnerSay("    https://github.com/missyrestless/PrivacyShield#readme");
    }

    changed(integer change) {
         if (change & (CHANGED_OWNER | CHANGED_INVENTORY)) {
             llResetScript();
         }
    }
}

state cloaked {
    state_entry() {
        defaultState = FALSE;
        listenerID = llListen(listenChannel, "", owner, "");
        objListenID = llListen(objChannel, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message) {
        string cmd = llToLower(message);
        if (channel == listenChannel) {
            if (DEBUG) llOwnerSay("Heard in cloaked state on listen channel: " + message);
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Down from cloaked state");
                llRegionSay(objChannel, "Shields Down");
                lowerShield();
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Up from cloaked state");
                llRegionSay(objChannel, "Shields Up");
                raiseShield();
                state default;
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Info from cloaked state");
                llRegionSay(objChannel, "Shields Info");
                stateShield();
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
            if (DEBUG) llOwnerSay("Heard in cloaked state on inter-object listen channel: " + message);
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                lowerShield();
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                raiseShield();
                state default;
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                stateShield();
            } else if (cmd == "flash off") {
                FLASH = FALSE;
            } else if (cmd == "flash on") {
                FLASH = TRUE;
            } else if (cmd == "phantom") {
                SOLID = FALSE;
            } else if (cmd == "solid") {
                SOLID = TRUE;
            } else if (cmd == "touch off") {
                TOUCH = FALSE;
            } else if (cmd == "touch on") {
                TOUCH = TRUE;
            }
        }
    }

    timer()
    {
        rcv_lower = FALSE;
        rcv_raise = FALSE;
        rcv_state = FALSE;
        llSetTimerEvent(0.0);
    }

    touch_start(integer num_detected) {
        // Ensure only the owner triggers the timer start check
        if (llDetectedKey(0) == owner) {
            llResetTime(); // Starts tracking duration
        }
    }

    touch_end(integer num_detected) {
        if (llDetectedKey(0) == owner) {
            float holdTime = llGetTime();

            if (TOUCH) {
                if (holdTime >= 1.0) {
                    // Long press for dialog menu
                    state menu;
                } else {
                    // Send the message to other objects in region with same owner listening on this channel
                    if (DEBUG) llOwnerSay("Sending Shields Up from cloaked state touch");
                    llRegionSay(objChannel, "Shields Up");
                    raiseShield();
                    state default;
                }
            } else {
                // If shield touch is disabled, click gets dialog menu too
                state menu;
            }
        }
    }
}

state menu
{
    state_entry()
    {
        displayMainMenu();
    }

    listen(integer channel, string name, key id, string message) {
        if (DEBUG) llOwnerSay("Heard in menu state on dialog channel: " + message);
        if (message == "UP") {
            rcv_raise = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Up from menu state");
                llRegionSay(objChannel, "Shields Up");
            }
            raiseShield();
            defaultState = TRUE;
        } else if (message == "DOWN") {
            rcv_lower = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner
                if (DEBUG) llOwnerSay("Sending Shields Down from menu state");
                llRegionSay(objChannel, "Shields Down");
            }
            lowerShield();
            defaultState = FALSE;
        } else if (message == "INFO") {
            rcv_state = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields Info from menu state");
                llRegionSay(objChannel, "Shields Info");
            }
            stateShield();
        } else if (message == "ALL") {
            ALL = TRUE;
        } else if (message == "SINGLE") {
            ALL = FALSE;
        } else if (message == "SIZE") {
            state size;
        } else if (message == "NO FLASH") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Flash Off from menu state");
                llRegionSay(objChannel, "Flash Off");
            }
            FLASH = FALSE;
        } else if (message == "FLASH") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Flash On from menu state");
                llRegionSay(objChannel, "Flash On");
            }
            FLASH = TRUE;
        } else if (message == "SOLID") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Solid from menu state");
                llRegionSay(objChannel, "Solid");
            }
            SOLID = TRUE;
            llSetStatus(STATUS_PHANTOM, FALSE);
        } else if (message == "PHANTOM") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Phantom from menu state");
                llRegionSay(objChannel, "Phantom");
            }
            SOLID = FALSE;
            llSetStatus(STATUS_PHANTOM, TRUE);
        } else if (message == "TOUCH OFF") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Touch Off from menu state");
                llRegionSay(objChannel, "Touch Off");
            }
            TOUCH = FALSE;
        } else if (message == "TOUCH ON") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Touch On from menu state");
                llRegionSay(objChannel, "Touch On");
            }
            TOUCH = TRUE;
        } else if (message == "EXIT") {
            // Return to the previous state
            if (defaultState) {
                state default;
            } else {
                state cloaked;
            }
        }
        // Re-send the dialog to keep the menu open
        displayMainMenu();
    }

    timer()
    {
        // Return to the previous state
        if (defaultState) {
            state default;
        } else {
            state cloaked;
        }
    }

    state_exit()
    {
        llSetTimerEvent(0);
    }
}

state size
{
    state_entry()
    {
        prim_size = llGetScale();
        displaySizeMenu();
    }

    listen(integer channel, string name, key id, string message) {
        if (message == "24x12") {
            prim_size.x = 24.0;
            prim_size.y = 12.0;
        } else if (message == "32x16") {
            prim_size.x = 32.0;
            prim_size.y = 16.0;
        } else if (message == "40x20") {
            prim_size.x = 40.0;
            prim_size.y = 20.0;
        } else if (message == "48x24") {
            prim_size.x = 48.0;
            prim_size.y = 24.0;
        } else if (message == "56x28") {
            prim_size.x = 56.0;
            prim_size.y = 28.0;
        } else if (message == "64x32") {
            prim_size.x = 64.0;
            prim_size.y = 32.0;
        } else if (message == "BACK") {
            state menu;
        } else if (message == "EXIT") {
            // Return to the previous state
            if (defaultState) {
                state default;
            } else {
                state cloaked;
            }
        }
        llSetScale(prim_size);
        // Re-send the dialog to keep the menu open
        displaySizeMenu();
    }

    timer()
    {
        // Return to the previous state
        if (defaultState) {
            state default;
        } else {
            state cloaked;
        }
    }

    state_exit()
    {
        llSetTimerEvent(0);
    }
}
