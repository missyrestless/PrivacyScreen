# Privacy Screen

Scripted land screen with easy transparency/phantom on/off

## Usage

The `Cloak` script is used by the Truth &amp; Beauty Privacy Screens.

Rez a Truth &amp; Beauty Privacy Screen and position it where you want.

Rez as many screens as you need, they can all be controlled using the
gestures described below.

### Gestures

Control the transparency and phantom status of Truth &amp; Beauty Privacy
Screens using gestures. Two gestures are provided, `Shields Up` and `Shields Down`.

Play the `Shields Up` gesture within 10 meters of any Truth &amp; Beauty Privacy
Screen and all rezzed screens within 100 meters will activate. The texture will
become visible and the screens will become solid preventing view and access.

Play the `Shields Down` gesture within 10 meters of any Truth &amp; Beauty Privacy
Screen and all rezzed screens within 100 meters will deactivate. The texture will
become transparent and the screens will become phantom allowing view and access.

Alternately, if the gestures are activated, saying `/up` in local chat will play
the `Shields Up` gesture and activate the screens. Saying `/down` in local chat
will play the `Shields Down` gesture and deactivate the screens.

If the gestures are not activated, say `/999 Up` in local chat to activate the screens
and `/999 Down` to deactivate.

## Resizing

The Truth &amp; Beauty Privacy Screens are Modify/Copy and can be resized to fit your needs.
To resize a screen:

- Right click the screen and select `Edit`
- Click the `Object` tab in the edit window
- Set the desired X and Y sizes in the `Size (meters)` section
- Close the Edit window

Alternately, in the Edit window click `Stretch` and use the handles to drag
the edges of the screen to the size you desire.

**[Note:]** The textures are in 2:1 ratio, width to height. When resizing, try to
remain fairly close to this aspect ratio. For example, resize a 32x16 screen to 48x24
or 64x32. Small variations from this aspect ratio should be fine. Larger variation
will begin to distort the image.

## Updates

To update a Truth &amp; Beauty Privacy Screen:

- Download the latest release from this repository
- Unzip the release archive
- Copy the `Cloak` script and paste it into a Second Life script
- Replace the `Cloak` script in the Privacy Screen with the downloaded version
  - Right click the screen and select `Edit`
  - Click the `Contents` tab in the edit window
  - Delete the `Cloak` script
  - Drag and Drop the newly downloaded `Cloak` script into the Contents tab
- Click the Reset Scripts button
- Close the Edit window
