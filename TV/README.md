# Truth &amp; Beauty Privacy Shield TV

The Truth &amp; Beauty Privacy Shield TV is based on the open source implementation of Media on a Prim by Void Singer at https://wiki.secondlife.com/wiki/User:Void_Singer/Teacup

This folder contains modified derivatives of `Teacup`, `Red Tea`, and associated files. These modifications provide integration and compatibility with Truth &amp; Beauty Privacy Shields.

## Privacy Shield TV Setup

1. Rez a Truth &amp; Beauty Privacy Shield version 2.0.1 or later
1. Copy `teacup.js` into a notecard named `teacup.js`, save it, and drop it in your rezzed shield
    - You May want to Edit this file to your liking first... You can add most valid javascript functions that do not rely on body onload behavior.
1. Copy `index.tsp` into a notecard named `index.tsp`, save it, and drop it in your rezzed shield
    - You May want to Edit this file to your liking first... You can use any html that is valid inside of a body tag.
1. Copy `page1.tsp` into a notecard named `page1.tsp`, save it, and drop it in your rezzed shield
    - You May want to Edit this file to your liking first... You can use any html that is valid inside of a body tag.
1. Copy `Red_Tea.lsl` into a script named `Red Tea`, save it, and drop it in your rezzed shield
1. Copy `Region_Stats.lsl` into a script named `Region Stats`, save it, and drop it into your rezzed shield.
1. Optional: Copy `Saucer.lsl` into a script named `Saucer`, save it, and drop it in your rezzed shield.
1. Optional: Copy `Tea_Strainer.lsl` into a script named `Tea Strainer`, save it, and drop it in your rezzed shield.
1. Copy `Teacup.lsl` into a script named `Teacup`, save it, and drop it in your rezzed shield.
1. Click on the top of your shield if your webpage isn't already showing.
    - TODO: provide Privacy Shield menu management instructions here
    - At this point you may want to rotate and/or resize your shield.
    - If you like, you have my express permission to download (right click, "save as") and edit (with whichever image editor you prefer) the `Teacup.png` file to use as the default texture of your website prim.
1. Show it off to your friends with Media on a Prim enabled viewers.

## Teacup Protocols

This document is not required reading for users, it is really only of use to scripters
looking to understand or extend it.

### Server Protocols

#### Outgoing Messages

The server has only two outgoing message formats. The first is general advertisement, and can be used by any File Service or extension to advertise information about itself.

```lsl
llMessageLinked( LINK_SET, TEACUP_MESSAGE, "Message", NULL_KEY );
```

Where `Message` is anything the script wants to advertise The server only sends one such message "Teacup URL Changed", and ignores messages sent by other scripts using this format.

When this message is sent, The current Address of the Server is placed in the prims hover text, other scripts may use the following to retrieve it

```lsl
string vStrAddress = llList2String( llGetLinkPrimitiveParams( SERVER_LINK_NUMBER, [PRIM_TEXT] ), 0 );
```

The text will either be the servers URL, the text "No URL".

The second Outgoing Message is a file request and has the format

```lsl
llMessageLinked( LINK_SET, TEACUP_MESSAGE, REQUEST_PAGE, REQUEST_KEY );
```
- TEACUP_MESSAGE: 418
- REQUEST_PAGE: the format is "<page name>?<search string>#ip=<decimal IP Address>&<post data>]
  - Ex: "index.tsp?#ip=127.0.0.1&" <-- file has no search string or post data -->
  - the page name can be parsed with

```lsl
string vStrPageName = llList2String( llParseStringKeepNulls( REQUEST_PAGE, [], ["?","#"] ), 0 );
```
- REQUEST_KEY: the return key for the requested data.

valid Server Requests can be detected by checking that REQUEST_KEY is a valid key, and that TEACUP_MESSAGE is 418.

#### Incoming Messages

The server expects it will receive a return message in the following format for any file request made...

```lsl
llMessageLinked( REQUEST_SOURCE, RESPONSE_CODE, FILE_TEXT, REQUEST_KEY ); //-- sent from the File Service
```
- REQUEST_SOURCE: The link number of the Teacup server that sent the request
- RESPONSE_CODE: the following standard HTTP Response codes are currently recognized
  - 100 "Continue": The server ignores this, make sure you send a normal response code as a follow up (see Saucer for details)
  - 200 "Success": Basic "yes we have it, here you go". anything that returns data can return this
  - 201 "Created": File was created for this request. probably best if the file was created for the request
  - 202 "Accepted": Request acknowledged/received (content optional) probably best for commands that generate in world actions
  - 204 "No Content": We got the request/data, but don't need to return anything. probably best for form data, FILE_TEXT should be blank.
  - 403 "Forbidden": We got the request, but aren't allowed to serve it. Expansion space for per user access (unused as of this writing).
  - 404 "Not Found": The file does not exist. Avoid using this unless you are reasonably sure the file isn't being served from another script.
- FILE_TEXT: text of the file that was requested.
- REQUEST_KEY: server request key for this file.

Any return should be done within 20 seconds or it's results will be ignored (Mostly an LSL limitation)

#### Special Ranges and limitations

To promote predictable data flows within a scripted object, The following are "Official" limits for scripts to be included as compatible resources

1. The 0xx Range is off limits and may not be used (for compatibility with scripts that may use low numbers)
1. All normal HTTP Response codes and ranges (1xx-5xx) are reserved... do not use them unless they make sense or the server can actually send them properly.
1. the Range of 6xx codes is reserved for use by File System scripts, limited to no more than 10 per range per script and will be registered by request, first (working script) come, first served. if you reasonably need more than 10, use the 8xx-9xx range
  - the following 6xx codes are are registered at this time
    - Saucer
      - 600 "File Removed" (sent with a file name and NULL_KEY)
      - 601 "File Added" (sent with a file name and NULL_KEY)
1. 7xx codes are reserved for future expansion
1. 8xx-9xx are unregulated, use at your own risk
1. All Codes must be below 1000 (this is to guarantee safe data transfer for other unrelated scripts)

To Promote Maximum Stability and Flexibility

1. Any Script that resides in the server prim should expect link messages of up to 40KiB
  - File Service Scripts should attempt to send files 30KiB or smaller
1. File Service Scripts should not broadcast any link message larger than 4KiB using LINK_THIS
  - Responses to requests should be targeted to the Server prim that requested the data for larger data sizes (optimally for ALL responses)
1. Scripts residing outside of the server prim should expect link messages with up to 4KiB of data (the max the server is able to request with normally)
1. ".tsp" pages with inline scripts should avoid using the following variable/function names
  - v0, v1, v2, v3 - v9 (these variables are used to: wrap the page for transport, serve as a loading container for pages, handle timeout messages for non-loading pages, and the rest being reserved for future support)
  - u0, u1, u2, u3 - u9 (these functions handle: watching for ".tsp" links to intercept, setting up the container for new ".tsp" requests, loading the ".tsp" files, and the rest being reserved for future support)
    - you can request a new page from javascript by calling u1('PageName.tsp');, however you may want to include some random info in the search string if refreshing the same page

### Teacup Server Page (".tsp") Format

Teacup serves a modified html page called a Teacup Server Page (".tsp"), to overcome limitations in the LSL HTTP-in behavior.

If a requested filename ends with ".tsp" it needs to conform to a specific format that is similar but not identical to the contents of a normal html webpage. To convert an html page into a tsp page, the follow actions must take place (an example of all of them may be found in the Red Tea File Service)

- The file name should end with ".tsp"
- The contents are limited to what's valid inside a normal html "body" tag.
- It also requires the following minor changes, made in order:
  1. all backslash characters must be converted to double backslashes (may be applied on a line by line basis)
    - eg:
      - `file_string = llDumpList2String( llParseStringKeepNulls( file_string, ["\\"], [] ), "\\\\" );`
  1. all single quote characters must be prefixed with a literal backslash (may be applied on a line by line basis)
    - eg:
      - `file_string = llDumpList2String( llParseStringKeepNulls( file_string, ["'"], [] ), "\\'" );`
  1. all line breaks should be converted to "\n" literals (may be applied on a line by line basis)
    - eg:
      - `file_string = llDumpList2String( llParseStringKeepNulls( file_string, ["\n"], [] ), "\\n" );`
  1. The page should be prefixed with "v0=''" and suffixed with "';" (applies only to the whole page)
    - eg:
      - `file_string = "v0='" + file_string + "';";`

## License

The Teacup webserver front end for Media on a Prim, Red Tea file service for Teacup, and associated scripts are released under the terms of a Creative Commons license:

```
/*//  Free to copy, use, modify, distribute, or sell, with attribution.   //*/
/*//    (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]    //*/
/*//   Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//  All usages must contain a plain text copy of the previous 2 lines.  //*/
/*//--                                                                  --//*/
```

This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

[![CC BY 4.0](https://mirrors.creativecommons.org/presskit/icons/cc.svg)](https://creativecommons.org/licenses/by/4.0/)

---

### Human-Readable Summary of the License

This is a human-readable summary of (and not a substitute for) the full [legal code](https://creativecommons.org/licenses/by/4.0/legalcode).

#### You are free to:
* **Share** — Copy and redistribute the material in any medium or format.
* **Remix** — Remix, transform, and build upon the material for any purpose, even commercially.

The licensor cannot revoke these freedoms as long as you follow the license terms.

#### Under the following terms:
* **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
