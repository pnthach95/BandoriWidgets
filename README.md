# BandoriWidgets
A Rainmeter skin to display current event information based on [Bestdori](https://bestdori.com/)'s API. Each server is loaded independently.

**Also, please don't forget your UTC offset in @Resources\variables.inc**

![alt text](/screenshot.png)


# Download
Open [Release](https://github.com/pnthach95/BandoriWidgets/releases) and download rmskin file

# Customization
Most customization can be done under `...\Rainmeter\skins\BandoriWidgets\@Resources\variables.inc`
For further customization, you can directly modify the skin files, but I wouldn't recommend touching anything below the `Measures` line.

To enable acrylic background, add `,0` (alpha channel) at the end of `XXBGColor` and `XXBorderColor` and change `XXTextColor` to make text readable (XX is server you choose).

![alt text](/acrylic.png)

# Additional notes
* The event name displayed will always be in that server's language. Ex: the japanese server displays the japanese name, etc
* You can use either the banner or the logo (a little more SFW!)
* You can change the banner/logo language as long as it is available (ex: you cannot use a language other than JP for the JP banner, etc.)
* You can change the language and scale of everything
