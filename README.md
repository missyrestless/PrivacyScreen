# Truth and Beauty Privacy Shield

The `Shield` LSL script is used by the Truth &amp; Beauty Privacy Shields, scripted land shields with easy transparency/phantom on/off. All Truth &amp; Beauty Privacy Shields in the same region with the same owner communicate with each other. For example, activating or deactivating one shield activates or deactivates them all. Shields can also be managed individually along with several other settings.

Privacy Shield sizes &amp; textures as well as settings are maintained as Linkset Datastore Key/Value pairs. No notecard is required and these settings persist across resets, deletion, copying, and region transfers without using script memory.

## Table of Contents

- [Buy](#buy)
- [Deploy](#deploy)
- [Manage with Dialog Menus](#manage-with-dialog-menus)
- [Manage with Gestures](#manage-with-gestures)
  - [Customize the Gestures](#customize-the-gestures)
- [Manual Resizing](#manual-resizing)
- [Updates](#updates)
- [Textures](#textures)
  - [Truth and Beauty Wikimedia Commons Textures](#truth-and-beauty-wikimedia-commons-textures)
  - [Other Creators](#other-creators)
- [License](#license)
- [Support](#support)

## Buy

[Purchase](https://marketplace.secondlife.com/p/Truth-Beauty-Privacy-Shield/28586403) the Truth &amp; Beauty Privacy Shield on the [Second Life Marketplace](https://marketplace.secondlife.com/p/Truth-Beauty-Privacy-Shield/28586403).

## Deploy

Rez a Truth &amp; Beauty Privacy Shield and position it where you want.

Rez as many shields as you need, they can all be controlled using the gestures described below, a dialog menu, or via local chat commands.

Truth &amp; Beauty Privacy Shields are provided as either a rectangular screen or tube shape. The rectangular screens also have a mirrored version to allow easy chaining of shields.

The Truth &amp; Beauty Privacy Shields include a variety of pleasant textures with which the shields can be configured. After rezzing, the default texture(s) can be replaced with those of your choosing using the main dialog menu `TEXTURE` button. Custom textures can be added by simply dragging and dropping a texture from your inventory into the Shield's Contents tab of the Edit window.

## Manage with Dialog Menus

The Truth &amp; Beauty Privacy Shields can be managed using dialog menus.

Open the management menu by clicking on a shield, If the shield is touch enabled (clicking toggles its status) then long press the shield (click and hold the mouse button down for 2 seconds). The main menu provides buttons to raise and lower the shields, set menu actions to all shields in region or a single shield, set the shield to single or double sided, and display info on all shields in the region. Several submenus are available including menus for resizing, retexturing, and configuring the shield settings.

<table>
  <tr>
    <td align="center"><img src="./Pics/MainMenu.png?raw=true" title="Main Menu" width="342" height="253" /></td>
    <td align="center"><img src="./Pics/TextureMenu.png?raw=true" title="Texture Menu" width="342" height="253" /></td>
  </tr>
</table>

These dialog menus provide a status indicator for all Truth &amp; Beauty Privacy Shields in the region and can be used to:

- Raise / Lower Shields
- Set to 1-sided shield (default) or 2-sided shield
- Apply changes to a single shield or all shields in the region owned by the same owner
- Enable/Disable Flashing when shields are activated
- Enable/Disable Touch to activate/deactivate shields
- Set shields to phantom or solid when active
- Resize shields to standard formats
- Retexture each shield with textures in the Shield inventory
  - New textures can be added, simply drag and drop into the shield Contents tab
  - Best if new textures are in 2:1 aspect ration, width twice the height
  - Keep texture names short, less than 11 characters, e.g. `MyFavorite`
- Set each shield to access by owner only or members of the shield's group
  - If group access is enabled, group members can manage shields via the dialog menu only
  - Owner can always manage via dialog menu or chat commands and gestures
  - Group members cannot enable or disable group access, only owner can

The Truth &amp; Beauty Privacy Shields store settings in prim K/V storage. No editing notecards, all preferences and settings are automatically saved in the prim K/V store.

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

## Manual Resizing

The Truth &amp; Beauty Privacy Shields are Modify/Copy and can be resized to fit your needs.

Shields can be resized to standard formats using the main dialog menu `SIZE` button.

To manually resize a shield:

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

## Textures

The textures provided and used by the Truth &amp; Beauty Privacy Shields are full perm and can be copied under the restrictions set forth by their creators. Typically these restrictions include no transfer of redistribution of the standalone images, they may be freely copied and used in your product builds and sold as part of those products.

The Truth &amp; Beauty Lab encourages the purchase of these high quality, low priced products from which the textures in the Privacy Shield were obtained:

### Truth and Beauty Wikimedia Commons Textures

- [Space](https://marketplace.secondlife.com/p/Wikimedia-Commons-Textures-Space/1609854)
- [Nudes](https://marketplace.secondlife.com/p/Wikimedia-Commons-Textures-Nudes/1609844)
- [Fungi](https://marketplace.secondlife.com/p/Wikimedia-Commons-Textures-Fungi/1609830)
- [Flowers](https://marketplace.secondlife.com/p/Wikimedia-Commons-Textures-Flowers/1609819)
- [Nature](https://marketplace.secondlife.com/p/Wikimedia-Commons-Textures-Nature/1132878)

### Other Creators

- [Sky stars 360 Seamless Panorama Texture](https://marketplace.secondlife.com/p/Sky-stars-360-Seamless-Panorama-Texture/26621462)
- [Textures Underwater World with Castle](https://marketplace.secondlife.com/p/Textures-Underwater-World-with-Castle/25115051)
- [Underwater 360 Seamless Panorama Texture](https://marketplace.secondlife.com/p/Underwater-360-Seamless-Panorama-Texture/26621490)
- [Fantasy-starburst 360 Seamless Panorama Texture](https://marketplace.secondlife.com/p/fantasy-starburst-360-Seamless-Panorama-Texture/26621416)
- [FaeTree Amazing Backgrounds V.6 Space](https://marketplace.secondlife.com/p/FaeTree-Amazing-Backgrounds-V6-Space/27120254)
- [Amazing Backgrounds V3](https://marketplace.secondlife.com/p/Amazing-Backgrounds-V3/20567584)
- [WoW 2 Underwater & Sand Textures](https://marketplace.secondlife.com/p/WoW-2-Underwater-Sand-Textures/26103618)
- [Out To Sea Panoramics](https://marketplace.secondlife.com/p/Out-To-Sea-Panoramics/19892222)
- [2 Underwater Textures](https://marketplace.secondlife.com/p/2-Underwater-Textures/28320813)

## License

The Truth &amp; Beauty Privacy Shield is distributed under the terms and conditions of the GNU General Public License (GPL). The GPL is a copyleft license, which means that it guarantees end users the freedom to run, study, share, or modify the software, but if you distribute a derivative work or modification, you must provide the source code to those recipients under the same or equivalent license terms — there is no requirement to publish anything to the public at large.

The full terms and conditions of the GPL are provided with the Truth &amp; Beauty Privacy Shield and can be found at https://www.gnu.org/licenses/gpl-3.0.html

The key conditions of the GPL, in simple English, include the following:

- You can run the program for any use
- You can see how the program works and change it
- You can share copies with others
- You can share your changed versions under the same rules

## Support

Issues with the Truth &amp; Beauty Privacy Shields can be opened in this repository.

Alternately, email missyrestless@gmail.com with questions, comments, suggestions, or flowers.
