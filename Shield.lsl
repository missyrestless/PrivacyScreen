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
// 2026-Aug-17 Add texture menu management        //
//                                                //
////////////////////////////////////////////////////

string  VERSION = "1.1.1";

integer ALL     = TRUE;      // Set to TRUE to effect all shields, FALSE for single shield
integer FLASH   = FALSE;     // Set to TRUE to flash when shield activates, FALSE to disable
integer GROUP   = FALSE;     // Set to TRUE to allow group members to manage, FALSE for owner only
integer SOLID   = TRUE;      // Set to FALSE for always phantom shields, TRUE phantom when invisible
integer TOUCH   = FALSE;     // Set to TRUE to enable touch toggles, FALSE to disable
integer listenerID;          // Not yet used
integer objListenID;         // Not yet used
integer dialogHandle;        // Dialog Menu listener handle, channel, boolean
integer listenHandle;
integer dialogChannel;
integer pageNumber    = 1;
integer defaultState  = TRUE;
integer selected_face = -1;
integer listenChannel = 0;   // Channel for chat and gestures
integer objChannel;          // Channel for communication between screens, based on owner
integer shieldStatus;        // TRUE if screen active, FALSE if screen is transparent
integer total_faces;         // Number of textured faces
integer rcv_lower;           // Boolean indicating recieved lower screen message
integer rcv_raise;           // Boolean indicating recieved raise screen message
integer rcv_state;           // Boolean indicating recieved state message

key     owner = NULL_KEY;
key     tcher = NULL_KEY;
list    faces = [];          // Faces with screen texture, all other faces will be transparent
list    texts = [];          // Face & Texture of faces with screen texture, for use as strided list
list    strid = [];          // Strided list of Faces & Textures
float   cloakSpeed =  0.1;
float   def_size_x = -1.0;
float   def_size_y = -1.0;
string  texture_prefix = "Shield_"; // Textures in object inventory beginning with Shield_ will be used
vector  prim_size;

// Linkset Data Keys
//
// Owner only linkset data key
// string  OWNER_O_LSD_KEY  = "owner_only";
// Online texture linkset data key
// string  ON_TXT_LSD_KEY   = "online_texture";
// Offline texture linkset data key
// string  OFF_TXT_LSD_KEY  = "offline_texture";
// Transparency linkset data key
// string  OPAQUE_LSD_KEY   = "is_transparent";

setFacesAlpha(float trans) {
    integer i;
    for (i = 0; i < total_faces; ++i)
    {
        llSetAlpha(trans, llList2Integer(faces, i));
    }
}

lowerShield() {
    float alpha = 1.0;
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
    string msg;

    if (shieldStatus == TRUE) {
        msg = prefix + location + " is VISIBLE and SOLID";
    } else {
        msg = prefix + location + " is TRANSPARENT and PHANTOM";
    }
    if (tcher == owner) {
        llOwnerSay(msg);
    } else {
        if (tcher) {
            llRegionSayTo(tcher, 0, msg);
        } else {
            llOwnerSay(msg);
        }
    }
    llSetTimerEvent(5.0);
}

// TODO: Add support for selecting and setting faces/textures
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
        if (prefix == llGetSubString(texture_name, 0, llStringLength(prefix) - 1)) {
            texture_list += llDeleteSubString(texture_name, 0, 6);
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
    dialogHandle = llListen(dialogChannel, "", tcher, "");
    list main_menu = [];
    string menuMessage;

    menuMessage = "\nTruth & Beauty Privacy Shield " + VERSION;
    if (ALL) {
        menuMessage += "\nMenu actions effect ALL SHIELDS IN REGION\n";
        menuMessage += "\nSINGLE = Menu actions effect only this shield";
    } else {
        menuMessage += "\nMenu actions effect ONLY THIS SHIELD\n";
        menuMessage += "\nALL = Menu actions effect all shields in region";
    }
    if (GROUP) {
        menuMessage += "\nOWNER = Owner only access";
    } else {
        menuMessage += "\nGROUP = Allow group members to manage";
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
        menuMessage += "\nTOUCH OFF = Touch opens dialog menu\n";
    } else {
        menuMessage += "\nTOUCH ON = Touch to raise/lower shields\n";
    }
    main_menu = ["UP", "DOWN", "INFO", "SIZE", "TEXTURE"];
    if (ALL) {
        main_menu += ["SINGLE"];
    } else {
        main_menu += ["ALL"];
    }
    if (GROUP) {
        main_menu += ["OWNER"];
    } else {
        main_menu += ["GROUP"];
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
    dialogHandle = llListen(dialogChannel, "", tcher, "");
    list size_menu = [];
    string menuMessage;

    menuMessage = "\nTruth & Beauty Privacy Shield Resize Menu";
    menuMessage = "\nResize this shield only\n";
    menuMessage += "\nCurrent shield size (X=Width, Y=Height):";
    menuMessage += "\n\tX: " + (string) ( prim_size.x );
    menuMessage += "\n\tY: " + (string) ( prim_size.y );
    menuMessage += "\n\tZ: " + (string) ( prim_size.z );
    size_menu = ["24x12", "32x16", "40x20", "48x24", "56x28", "64x32"];
    size_menu += ["BACK", "RESTORE", "EXIT"];
    ShowMenu(menuMessage, size_menu);
}

displayTextMenu() {
    llListenRemove(dialogHandle);
    dialogHandle = llListen(dialogChannel, "", tcher, "");
    list face_menu = ["BACK", "RESTORE", "EXIT"];
    list text_menu = [];
    string menuMessage;

    menuMessage = "\nTruth & Beauty Privacy Shield Texture Menu";
    text_menu = get_Textures(texture_prefix);
    if (text_menu) {
        menuMessage += "\nTexture this shield only\n";
        menuMessage += "\nSelect a face then select the texture to use on that face\n";

        integer total = llGetListLength(faces);
        integer i;
        for (i = 0; i < total; ++i) {
            face_menu += "Face " + llList2String(faces, i);
        }
        face_menu += text_menu;
    } else {
        menuMessage += "\nNO TEXTURES FOUND\n";
    }
    ShowMenu(menuMessage, face_menu);
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
            if (pageNumber > 1) displayList += ["<<< Prev"];
            if (pageNumber < totalPages) displayList += ["Next >>>"];
        }

        // Send the dialog page
        llDialog(tcher, msg + " (Page " + (string)pageNumber + " of " +
                (string)totalPages + "):", arrange(displayList), dialogChannel);
    } else {
        // Send the dialog
        llDialog(tcher, msg, arrange(fm), dialogChannel);
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

// TODO: Add support for storing settings in prim K/V linkset datastore
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

        owner        = llGetOwner();
        tcher        = NULL_KEY;
        defaultState = TRUE;
        if (llGetAlpha(ALL_SIDES) > 0.0) {
            shieldStatus = TRUE;
        } else {
            shieldStatus = FALSE;
        }
        // Set default prim size if not yet set
        if ((def_size_x == -1.0) || (def_size_y == -1.0)) {
            prim_size = llGetScale();
            def_size_x = prim_size.x;
            def_size_y = prim_size.y;
        }

        integer numOfSides = llGetNumberOfSides();
        integer i;
        // Find which faces are textured with non-default textures
        faces = [];
        for (i = 0; i < numOfSides; ++i) {
            currentTex = llGetTexture(i);
            if ((currentTex != DEFAULT_PLYWOOD) &&
                (currentTex != TTRANSPARENT) &&
                (currentTex != BLANK) &&
                (currentTex != WHITE_TEXTURE) &&
                (currentTex != "*Default Transparent Texture") &&
                (currentTex != NULL_KEY)) {
                faces += i;
                texts += [i, currentTex];
            }
        }
        strid = llList2ListStrided(texts, 0, -1, 2);

        total_faces  = llGetListLength(faces);
        // Compute a large negative channel number based on the object owner
        // All screens owned by the same owner will use the same channel
        objChannel = 0x80000000 | (integer) ( "0x" + (string) owner );
        // TODO: Filter listen for group members
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
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Down");
                lowerShield();
                state cloaked;
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Up");
                raiseShield();
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Info");
                stateShield();
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
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
            } else if (cmd == "group") {
                GROUP = TRUE;
            } else if (cmd == "owner") {
                GROUP = FALSE;
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

    timer() {
        rcv_lower = FALSE;
        rcv_raise = FALSE;
        rcv_state = FALSE;
        llSetTimerEvent(0.0);
    }

    touch_start(integer num_detected) {
        tcher = llDetectedKey(0);
        // Ensure only the owner or group members triggers the timer start check
        if (GROUP) {
            if ((llDetectedGroup(0)) || (tcher == owner)) {
                llResetTime(); // Starts tracking duration
            } else {
                tcher = NULL_KEY;
            }
        } else {
            if (tcher == owner) {
                llResetTime(); // Starts tracking duration
            } else {
                tcher = NULL_KEY;
            }
        }
    }

    touch_end(integer num_detected) {
        float holdTime = llGetTime();
        if (GROUP) {
            if ((llDetectedGroup(0)) || (tcher == owner)) {
                if (TOUCH) {
                    if (holdTime >= 1.0) {
                        // Long press for dialog menu
                        // Handle dialog menu in its own state
                        state menu;
                    } else {
                        if (llGetAlpha(ALL_SIDES) > 0.0) {
                            llRegionSay(objChannel, "Shields Down");
                            lowerShield();
                            state cloaked;
                        } else {
                            llRegionSay(objChannel, "Shields Up");
                            raiseShield();
                            state default;
                        }
                    }
                } else {
                    // If shield touch is disabled, display dialog menu on clicks as well
                    state menu;
                }
            }
        } else {
            if (tcher == owner) {
                if (TOUCH) {
                    if (holdTime >= 1.0) {
                        // Long press for dialog menu
                        // Handle dialog menu in its own state
                        state menu;
                    } else {
                        if (llGetAlpha(ALL_SIDES) > 0.0) {
                            llRegionSay(objChannel, "Shields Down");
                            lowerShield();
                            state cloaked;
                        } else {
                            llRegionSay(objChannel, "Shields Up");
                            raiseShield();
                            state default;
                        }
                    }
                } else {
                    // If shield touch is disabled, display dialog menu on clicks as well
                    state menu;
                }
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
        prim_size = llGetScale();
        def_size_x = prim_size.x;
        def_size_y = prim_size.y;
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
        tcher = NULL_KEY;
        // TODO: Filter listen for group members
        listenerID = llListen(listenChannel, "", owner, "");
        objListenID = llListen(objChannel, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message) {
        string cmd = llToLower(message);
        if (channel == listenChannel) {
            if (cmd == "shields down") {
                if (rcv_lower) return;
                rcv_lower = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Down");
                lowerShield();
            } else if (cmd == "shields up") {
                if (rcv_raise) return;
                rcv_raise = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Up");
                raiseShield();
                state default;
            } else if (cmd == "shields info") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Info");
                stateShield();
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
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
            } else if (cmd == "group") {
                GROUP = TRUE;
            } else if (cmd == "owner") {
                GROUP = FALSE;
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

    timer() {
        rcv_lower = FALSE;
        rcv_raise = FALSE;
        rcv_state = FALSE;
        llSetTimerEvent(0.0);
    }

    touch_start(integer num_detected) {
        tcher = llDetectedKey(0);
        // Ensure only the owner or group members triggers the timer start check
        if (GROUP) {
            if ((llDetectedGroup(0)) || (tcher == owner)) {
                llResetTime(); // Starts tracking duration
            } else {
                tcher = NULL_KEY;
            }
        } else {
            if (tcher == owner) {
                llResetTime(); // Starts tracking duration
            } else {
                tcher = NULL_KEY;
            }
        }
    }

    touch_end(integer num_detected) {
        float holdTime = llGetTime();
        if (GROUP) {
            if ((llDetectedGroup(0)) || (tcher == owner)) {
                if (TOUCH) {
                    if (holdTime >= 1.0) {
                        // Long press for dialog menu
                        state menu;
                    } else {
                        if (llGetAlpha(ALL_SIDES) > 0.0) {
                            llRegionSay(objChannel, "Shields Down");
                            lowerShield();
                            state cloaked;
                        } else {
                            llRegionSay(objChannel, "Shields Up");
                            raiseShield();
                            state default;
                        }
                    }
                } else {
                    // If shield touch is disabled, click gets dialog menu too
                    state menu;
                }
            }
        } else {
            if (tcher == owner) {
                if (TOUCH) {
                    if (holdTime >= 1.0) {
                        // Long press for dialog menu
                        state menu;
                    } else {
                        if (llGetAlpha(ALL_SIDES) > 0.0) {
                            llRegionSay(objChannel, "Shields Down");
                            lowerShield();
                            state cloaked;
                        } else {
                            llRegionSay(objChannel, "Shields Up");
                            raiseShield();
                            state default;
                        }
                    }
                } else {
                    // If shield touch is disabled, click gets dialog menu too
                    state menu;
                }
            }
        }
    }
}

state menu
{
    state_entry() {
        displayMainMenu();
    }

    listen(integer channel, string name, key id, string message) {
        if (message == "UP") {
            rcv_raise = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Up");
            }
            raiseShield();
            defaultState = TRUE;
        } else if (message == "DOWN") {
            rcv_lower = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner
                llRegionSay(objChannel, "Shields Down");
            }
            lowerShield();
            defaultState = FALSE;
        } else if (message == "INFO") {
            rcv_state = TRUE;
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Shields Info");
            }
            stateShield();
        } else if (message == "ALL") {
            ALL = TRUE;
        } else if (message == "SINGLE") {
            ALL = FALSE;
        } else if (message == "SIZE") {
            state size;
        } else if (message == "TEXTURE") {
            state text;
        } else if (message == "GROUP") {
            if (id == owner) {
                if (ALL) {
                    // Send the message to other objects in region with same owner listening on this channel
                    llRegionSay(objChannel, "Group");
                }
                GROUP = TRUE;
            } else {
                if (id) llRegionSayTo(id, 0, "Only the owner can set the shields to group access");
            }
        } else if (message == "OWNER") {
            if (id == owner) {
                if (ALL) {
                    // Send the message to other objects in region with same owner listening on this channel
                    llRegionSay(objChannel, "Owner");
                }
                GROUP = FALSE;
            } else {
                if (id) llRegionSayTo(id, 0, "Only the owner can set the shields to owner only");
            }
        } else if (message == "NO FLASH") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Flash Off");
            }
            FLASH = FALSE;
        } else if (message == "FLASH") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Flash On");
            }
            FLASH = TRUE;
        } else if (message == "SOLID") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Solid");
            }
            SOLID = TRUE;
            llSetStatus(STATUS_PHANTOM, FALSE);
        } else if (message == "PHANTOM") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Phantom");
            }
            SOLID = FALSE;
            llSetStatus(STATUS_PHANTOM, TRUE);
        } else if (message == "TOUCH OFF") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
                llRegionSay(objChannel, "Touch Off");
            }
            TOUCH = FALSE;
        } else if (message == "TOUCH ON") {
            if (ALL) {
                // Send the message to other objects in region with same owner listening on this channel
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

    timer() {
        // Return to the previous state
        if (defaultState) {
            state default;
        } else {
            state cloaked;
        }
    }

    state_exit() {
        llSetTimerEvent(0);
    }
}

state size
{
    state_entry() {
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
        } else if (message == "RESTORE") {
            prim_size.x = def_size_x;
            prim_size.y = def_size_y;
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

    timer() {
        // Return to the previous state
        if (defaultState) {
            state default;
        } else {
            state cloaked;
        }
    }

    state_exit() {
        llSetTimerEvent(0);
    }
}

state text
{
    state_entry() {
        selected_face = -1;
        displayTextMenu();
    }

    listen(integer channel, string name, key id, string message) {
        if ("Face " == llGetSubString(message, 0, 4)) {
            // Face #
            selected_face = (integer)(llGetSubString(message, 5, -1));
        } else if (message == "RESTORE") {
            integer len = llGetListLength(strid);
            integer i = 0;
            while (i < len) {
                // current
                llSetTexture(llList2String(strid, i + 1), llList2Integer(strid, i));
                i += 2; // Jump to the next stride
            }
        } else if (message == "BACK") {
            state menu;
        // Handle pagination for multi page menus
        } else if (message == "<<< Prev") {
            pageNumber--;
        } else if (message == "Next >>>") {
            pageNumber++;
        } else if (message == "EXIT") {
            // Return to the previous state
            if (defaultState) {
                state default;
            } else {
                state cloaked;
            }
        } else {
            string txt_name = texture_prefix + message;
            if (llGetInventoryType(txt_name) == INVENTORY_TEXTURE) {
                if (selected_face == -1) {
                    llRegionSayTo(tcher, 0, "Select a face to texture first");
                    state warn;
                } else {
                    llSetTexture(txt_name, selected_face);
                }
            } else {
                llRegionSayTo(tcher, 0, "The texture is missing or not a texture: " + txt_name);
            }
        }
        // Re-send the dialog to keep the menu open
        displayTextMenu();
    }

    timer() {
        // Return to the previous state
        if (defaultState) {
            state default;
        } else {
            state cloaked;
        }
    }

    state_exit() {
        llSetTimerEvent(0);
    }
}

state warn
{
    state_entry() {
        integer warnChannel = -999999;
        llListenRemove(listenHandle);
        listenHandle = llListen(warnChannel, "", tcher, "");

        llDialog(tcher, "\nSelect a face to texture first\n", ["OK"], warnChannel);
        llSetTimerEvent(30.0); // 30-second timer
    }

    listen(integer channel, string name, key id, string message) {
        llSetTimerEvent(0.0);       // Stop timer
        llListenRemove(listenHandle); // Remove listener
        state text;
    }

    timer() {
        llSetTimerEvent(0.0);       // Stop timer
        llListenRemove(listenHandle); // Remove listener
        state text;
    }
}

