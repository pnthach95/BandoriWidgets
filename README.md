# BandoriWidgets
A Rainmeter skin to display current event information based on [Bestdori](https://bestdori.com/)'s API for GBP and [bdon.yatta.moe](https://bdon.yatta.moe)'s API for Our Notes. Each server is loaded independently.

**Also, please don't forget your UTC offset and language in `@Resources\variables.inc` for GBP and `@Resources\ournotes.inc` for Our Notes**

![alt text](/screenshot.png)


# Download
Open [Release](https://github.com/pnthach95/BandoriWidgets/releases) and download rmskin file

# Customization
Most customization can be done under `@Resources\variables.inc` for GBP, and `@Resources\ournotes.inc` for Our Notes.
For further customization, you can directly modify the skin files, but I wouldn't recommend touching anything below the `Measures` line.

To enable acrylic background, add `,0` (alpha channel) at the end of `XXBGColor` and `XXBorderColor` and change `XXTextColor` to make text readable (XX is server you choose).

![alt text](/acrylic.png)

# Additional notes
* The skins require 2 plug-ins: [RainJIT](https://github.com/F4Jonatas/RainJIT), [FrostedGlass](https://github.com/TheAzack9/FrostedGlass). It is included in rmskin file and should be installed.
* The event name displayed will always be in that server's language. Ex: the Japanese server displays the Japanese name, etc
* You can use either the banner or the logo (a little more SFW!)
* You can change the banner/logo language as long as it is available (ex: you cannot use a language other than JP for the JP banner, etc.)
* You can change the language and scale of everything
