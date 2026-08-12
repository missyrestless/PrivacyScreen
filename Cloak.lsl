///////////////////////////////////////////////////////////////////////////////////
//      Toggle Face 0 Transparency with Touch or Message on Listen Channel       //
//                                                                               //
// Message or Touch by owner of object toggles Face 0 transparency               //
// Face 5 is transparent and flashes 3 times when Face 0 becomes visible         //
// Listens on channel 999 for trigger messages to cloak or become invisible      //
// Shouts to other objects with same owner to trigger toggle command             //
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
integer objChannel = -99966; // Channel for llShout between screens

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
        listenerID = llListen(listenChannel, "", llGetOwner(), "");
        objListenID = llListen(objChannel, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message) {
        string cmd = llToLower(message);
        if (channel == listenChannel) {
            if (DEBUG) llOwnerSay("Heard in default state on chat/gesture listen channel: " + message);
            if (cmd == "down") {
                // Shout the message to any other objects listening on this channel
                if (DEBUG) llOwnerSay("Shouting Down from default state");
                llShout(objChannel, "Down");
                lowerShield();
                state cloaked;
            } else if (cmd == "up") {
                // Shout the message to any other objects listening on this channel
                if (DEBUG) llOwnerSay("Shouting Up from default state");
                llShout(objChannel, "Up");
                raiseShield();
            }
        } else if (channel == objChannel) {
            // Don't shout the message if we are receiving a shouted message
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
            // Shout the message to any other objects listening on this channel
            if (DEBUG) llOwnerSay("Shouting Down from default state touch");
            llShout(objChannel, "Down");
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
                // Shout the message to any other objects listening on this channel
                if (DEBUG) llOwnerSay("Shouting Down from cloaked state");
                llShout(objChannel, "Down");
                lowerShield();
            } else if (cmd == "up") {
                // Shout the message to any other objects listening on this channel
                if (DEBUG) llOwnerSay("Shouting Up from cloaked state");
                llShout(objChannel, "Up");
                raiseShield();
                state default;
            }
        } else if (channel == objChannel) {
            // Don't shout the message if we are receiving a shouted message
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
            // Shout the message to any other objects listening on this channel
            if (DEBUG) llOwnerSay("Shouting Up from cloaked state touch");
            llShout(objChannel, "Up");
            raiseShield();
            state default;
        }
      }
    }
}
