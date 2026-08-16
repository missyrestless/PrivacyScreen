# Truth and Beauty Privacy Shield

The `Shield` LSL script is used by the Truth &amp; Beauty Privacy Shields, scripted land shields with easy transparency/phantom on/off. All Truth &amp; Beauty Privacy Shields in the same region with the same owner communicate with each other. Activating or deactivating one shield activates or deactivates them all.

## Table of Contents

- [Deploy](#deploy)
- [Manage with Gestures](#manage-with-gestures)
  - [Customize the Gestures](#customize-the-gestures)
- [Manage with Dialog Menu](#manage-with-dialog-menu)
- [Manual Resizing](#manual-resizing)
- [Updates](#updates)
- [Support](#support)

## Deploy

Rez a Truth &amp; Beauty Privacy Shield and position it where you want.

Rez as many shields as you need, they can all be controlled using the gestures described below, a dialog menu, or via local chat commands.

## Manage with Gestures

Control the transparency and phantom status of Truth &amp; Beauty Privacy Shields using gestures. Three gestures are provided, `Shields Up`, `Shields Down`, and `Shields Info`.

Activate the `Shields Up`, `Shields Down`, and `Shields Info` gestures:

- Right click the `Shields Up` gesture in your inventory
- Select `Activate`
- Right click the `Shields Down` gesture in your inventory
- Select `Activate`
- Right click the `Shields Info` gesture in your inventory
- Select `Activate`

Once the gestures are activated:

- Saying `/up` in local chat will play the `Shields Up` gesture and activate the shields
  - All rezzed shields in the same region owned by the same owner will activate
  - The texture(s) will become visible and the shields will become solid preventing view and access
- Saying `/down` in local chat will play the `Shields Down` gesture and deactivate the shields
  - All rezzed shields in the same region owned by the same owner will deactivate
  - The texture(s) will become transparent and the shields will become phantom allowing view and access
- Saying `/info` in local chat will play the `Shields Info` gesture and display all shields' status

If the gestures are not activated, say `Shields Up` in local chat to activate the shields and `Shields Down` to deactivate. If you are far from any shield then shout the command, e.g. `/shout Shields Up` or `/shout Shields Down`.

### Customize the Gestures

The Truth &amp; Beauty Privacy Shields gestures are copy/modify so you can edit them if you like. If the trigger phrase conflicts with another gesture or you want to change it for any reason:

- Right click the gesture you wish to modify
- Select `Open`
- Modify the `Trigger:` entry to your custom trigger
  - DO NOT modify the `Replace with:` entry
- Click the `Save` button and close the gesture window

## Manage with Dialog Menu

The Truth &amp; Beauty Privacy Shields can be managed using a dialog menu. To bring up the menu, long press the shield.

The dialog menu provides a status indicator for all Truth &amp; Beauty Privacy Shields in the region and can be used to:

- Raise / Lower Shields
- Enable/Disable Debug Mode
- Enable/Disable Flashing when shields are activated
- Enable/Disable Touch to activate/deactivate shields
- Set shields to phantom or solid when active
- Resize shields to standard formats
- Select face / Select texture

The Truth &amp; Beauty Privacy Shields store settings in prim K/V storage. No editing notecards, all preferences and settings are automatically saved in the prim K/V store.

## Manual Resizing

The Truth &amp; Beauty Privacy Shields are Modify/Copy and can be resized to fit your needs. To resize a shield:

- Right click the shield and select `Edit`
- Click the `Object` tab in the edit window
- Set the desired X and Y sizes in the `Size (meters)` section
- Close the Edit window

Alternately, in the Edit window click `Stretch` and use the handles to drag the edges of the shield to the size you desire.

Truth &amp; Beauty Privacy Shields can also be resized to several standard sizes using the dialog menu.

**[Note:]** The textures are in 2:1 ratio, width to height. When resizing, try to remain fairly close to this aspect ratio. For example, resize a 32x16 shield to 48x24 or 64x32. Small variations from this aspect ratio should be fine. Larger variation will begin to distort the image.

## Updates

To update a Truth &amp; Beauty Privacy Shield:

- Download the latest release artifact from https://github.com/missyrestless/PrivacyShield/releases
  - Download the gzip'd tar archive or simply the `Shield.lslo` optimized LSL script
- Extract the gzip'd tar release archive if downloaded
- Copy the `Shield.lslo` script and paste it into a Second Life script named `Shield`
- Replace the `Shield` script in the Privacy Shield with the downloaded version
  - Right click the shield and select `Edit`
  - Click the `Contents` tab in the edit window
  - Delete the `Shield` script
  - Drag and Drop the newly downloaded `Shield` script into the Contents tab
- Close the Edit window

## Support

Issues with the Truth &amp; Beauty Privacy Shields can be opened in this repository.

Alternately, email missyrestless@gmail.com with questions, comments, suggestions, or flowers.
