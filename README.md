# Truth and Beauty Privacy Shield

The `Shield` LSL script is used by the Truth &amp; Beauty Privacy Shields, scripted land shields with easy transparency/phantom on/off. All Truth &amp; Beauty Privacy Shields in the same region with the same owner communicate with each other. Activating or deactivating one shield activates or deactivates them all.

## Table of Contents

- [Deploy](#deploy)
- [Manage with Gestures](#manage-with-gestures)
- [Manage with Dialog Menu](#manage-with-dialog-menu)
- [Manual Resizing](#manual-resizing)
- [Updates](#updates)
- [Support](#support)

## Deploy

Rez a Truth &amp; Beauty Privacy Shield and position it where you want.

Rez as many shields as you need, they can all be controlled using the gestures described below, a dialog menu, or via local chat commands.

## Manage with Gestures

Control the transparency and phantom status of Truth &amp; Beauty Privacy Shields using gestures. Two gestures are provided, `Shields Up` and `Shields Down`.

Activate the `Shields Up` and `Shields Down` gestures:

- Right click the `Shields Up` gesture in your inventory
- Select `Activate`
- Right click the `Shields Down` gesture in your inventory
- Select `Activate`

Once the gestures are activated:

- Saying `/up` in local chat will play the `Shields Up` gesture and activate the shields
  - All rezzed shields in the same region owned by the same owner will activate
  - The texture(s) will become visible and the shields will become solid preventing view and access
- Saying `/down` in local chat will play the `Shields Down` gesture and deactivate the shields
  - All rezzed shields in the same region owned by the same owner will deactivate
  - The texture(s) will become transparent and the shields will become phantom allowing view and access

If the gestures are not activated, say `Shields Up` in local chat to activate the shields and `Shields Down` to deactivate. If you are far from any shield then shout the command, e.g. `/shout Shields Up` or `/shout Shields Down`.

## Manage with Dialog Menu

The Truth &amp; Beauty Privacy Shields can be managed using a dialog menu. To bring up the menu, long press the shield.

The dialog menu provides a status indicator for all Truth &amp; Beauty Privacy Shields in the region and can be used to:

- Raise / Lower Shields
- Enable/Disable Debug Mode
- Enable/Disable Touch to activate/deactivate shields
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

- Download the latest release from this repository
- Unzip the release archive
- Copy the `Shield` script and paste it into a Second Life script
- Replace the `Shield` script in the Privacy Shield with the downloaded version
  - Right click the shield and select `Edit`
  - Click the `Contents` tab in the edit window
  - Delete the `Shield` script
  - Drag and Drop the newly downloaded `Shield` script into the Contents tab
- Click the Reset Scripts button
- Close the Edit window

## Support

Issues with the Truth &amp; Beauty Privacy Shields can be opened in this repository.

Alternately, email missyrestless@gmail.com with questions, comments, suggestions, or flowers.
