///////////////////////////////////////////////////////////////////////////////////
//      Toggle Face 0 Transparency with Touch or Message on Listen Channel       //
//                                                                               //
// Message or Touch by owner of object toggles Face 0 transparency               //
// Face 5 is transparent and flashes 3 times when Face 0 becomes visible         //
// Listens on channel 999 for trigger messages to cloak or become invisible      //
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

float   cloakSpeed = 0.1;
integer DEBUG = FALSE;       // Set to TRUE for debug messages to owner, FALSE to disable
integer TOUCH = FALSE;       // Set to TRUE to enable touch toggles, FALSE to disable
integer face  = 0;           // Face with screen texture, all other faces will be transparent
integer listenerID;          // Not yet used
integer objListenID;         // Not yet used
integer listenChannel = 999; // Channel for chat and gestures
integer objChannel;          // Channel for communication between screens, based on owner

lowerShield() {
    float alpha = 1.0;
    if (DEBUG) llOwnerSay("Lowering shield");
    while(alpha > 0.0) {
        alpha -= 0.1;
        llSetAlpha(alpha, face);
        llSleep(cloakSpeed);
    }
    llSetAlpha(0.0, ALL_SIDES);
    llSetStatus(STATUS_PHANTOM, TRUE);
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
        llSetAlpha(alpha, face);
        llSleep(cloakSpeed);
    }
    llSetStatus(STATUS_PHANTOM, FALSE);
}

default {
    state_entry() {
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
            if (cmd == "down") {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Down from default state");
                llRegionSay(objChannel, "Down");
                lowerShield();
                state cloaked;
            } else if (cmd == "up") {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Up from default state");
                llRegionSay(objChannel, "Up");
                raiseShield();
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
            if (DEBUG) llOwnerSay("Heard in default state on inter-object listen channel: " + message);
            if (cmd == "down") {
                lowerShield();
                state cloaked;
            } else if (cmd == "up") {
                raiseShield();
            }
        }
    }

    touch_end(integer total_number) {
      if (TOUCH) {
        if (llDetectedKey(0) == llGetOwner()) {
            // Send the message to other objects in region with same owner listening on this channel
            if (DEBUG) llOwnerSay("Sending Down from default state touch");
            llRegionSay(objChannel, "Down");
            lowerShield();
            state cloaked;
        }
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
            if (cmd == "down") {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Down from cloaked state");
                llRegionSay(objChannel, "Down");
                lowerShield();
            } else if (cmd == "up") {
                // Send the message to other objects in region with same owner listening on this channel
                if (DEBUG) llOwnerSay("Sending Up from cloaked state");
                llRegionSay(objChannel, "Up");
                raiseShield();
                state default;
            }
        } else if (channel == objChannel) {
            // Don't resend the message if we are receiving a message on this channel
            if (DEBUG) llOwnerSay("Heard in cloaked state on inter-object listen channel: " + message);
            if (cmd == "down") {
                lowerShield();
            } else if (cmd == "up") {
                raiseShield();
                state default;
            }
        }
    }

    touch_end(integer total_number) {
      if (TOUCH) {
        if (llDetectedKey(0) == llGetOwner()) {
            // Send the message to other objects in region with same owner listening on this channel
            if (DEBUG) llOwnerSay("Sending Up from cloaked state touch");
            llRegionSay(objChannel, "Up");
            raiseShield();
            state default;
        }
      }
    }
}
