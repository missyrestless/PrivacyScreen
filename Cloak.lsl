///////////////////////////////////////////////////////////////////////////////////
//     Toggle Transparency & Phantom with Touch or Message on Listen Channel     //
//                                                                               //
// Message or Touch by owner of object toggles Face 0 transparency               //
// Listens on channel 0 for trigger messages to cloak or become invisible        //
// Messages other objects in region with same owner to trigger toggle command    //
// When cloaked the prim phantom status is false, when invisible phantom is true //
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
//                                                //
////////////////////////////////////////////////////

float   cloakSpeed = 0.1;
integer DEBUG = FALSE;       // Set to TRUE for debug messages to owner, FALSE to disable
integer TOUCH = FALSE;       // Set to TRUE to enable touch toggles, FALSE to disable
integer listenerID;          // Not yet used
integer objListenID;         // Not yet used
integer listenChannel = 0;   // Channel for chat and gestures
integer objChannel;          // Channel for communication between screens, based on owner
integer shieldStatus;        // TRUE if screen active, FALSE if screen is transparent
integer total_faces;         // Number of textured faces
integer rcv_lower;           // Boolean indicating recieved lower screen message
integer rcv_raise;           // Boolean indicating recieved raise screen message
integer rcv_state;           // Boolean indicating recieved state message
list    faces = [];          // Faces with screen texture, all other faces will be transparent

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
    alpha = 0.0;
    llSetAlpha(alpha, ALL_SIDES);
    while (alpha < 1.0) {
        alpha += 0.1;
        setFacesAlpha(alpha);
        llSleep(cloakSpeed);
    }
    llSetStatus(STATUS_PHANTOM, FALSE);
    shieldStatus = TRUE;
    llSetTimerEvent(5.0);
}

stateShield() {
    string prefix = "Truth & Beauty Privacy Shield";
    vector currentPos = llGetPos();
    string regionName = llGetRegionName();

    // Round coordinates to whole integers
    integer x = (integer)currentPos.x;
    integer y = (integer)currentPos.y;
    integer z = (integer)currentPos.z;
    string coords = (string)x + "/" + (string)y + "/" + (string)z;

    // Construct the Slurl
    string slurl = "https://maps.secondlife.com/secondlife/" + regionName + "/" + coords;

    string location = " at " + slurl;
    if (shieldStatus == TRUE) {
        llOwnerSay(prefix + location + " is visible and solid");
    } else {
        llOwnerSay(prefix + location + " is transparent and phantom");
    }
    llSetTimerEvent(5.0);
}

default {
    state_entry() {
        string currentTex;
        string DEFAULT_PLYWOOD     = "89556747-24cb-43ed-920b-47caed15465f";
        string BLANK               = "5b53359e-59dd-d8a2-04c3-9e65134da47a";
        string TTRANSPARENT        = "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903";
        string WHITE_TEXTURE       = "5748decc-f629-461c-9a36-a35a221fe21f";

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

        // Compute a large negative channel number based on the object owner
        // All screens owned by the same owner will use the same channel
        objChannel = 0x80000000 | (integer) ( "0x" + (string) llGetOwner() );
        if (DEBUG) llOwnerSay("Computed owner object channel: " + (string)objChannel);
        listenerID = llListen(listenChannel, "", llGetOwner(), "");
        objListenID = llListen(objChannel, "", NULL_KEY, "");
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
            } else if (cmd == "shields state") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields State from default state");
                llRegionSay(objChannel, "Shields State");
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
            } else if (cmd == "shields state") {
                if (rcv_state) return;
                rcv_state = TRUE;
                stateShield();
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

    touch_end(integer total_number) {
      if (TOUCH) {
        if (llDetectedKey(0) == llGetOwner()) {
            // Send the message to other objects in region with same owner listening on this channel
            if (DEBUG) llOwnerSay("Sending Shields Down from default state touch");
            llRegionSay(objChannel, "Shields Down");
            lowerShield();
            state cloaked;
        }
      }
    }

    on_rez(integer num) {
        llResetScript();
        raiseShield();
    }

    changed(integer change) {
         if (change & (CHANGED_OWNER | CHANGED_INVENTORY)) {
             llResetScript();
         }
    }
}

state cloaked {
    state_entry() {
        listenerID = llListen(listenChannel, "", llGetOwner(), "");
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
            } else if (cmd == "shields state") {
                if (rcv_state) return;
                rcv_state = TRUE;
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Shields State from cloaked state");
                llRegionSay(objChannel, "Shields State");
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
            } else if (cmd == "shields state") {
                if (rcv_state) return;
                rcv_state = TRUE;
                stateShield();
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

    touch_end(integer total_number) {
      if (TOUCH) {
        if (llDetectedKey(0) == llGetOwner()) {
            // Send the message to other objects in region with same owner listening on this channel
            if (DEBUG) llOwnerSay("Sending Shields Up from cloaked state touch");
            llRegionSay(objChannel, "Shields Up");
            raiseShield();
            state default;
        }
      }
    }
}
