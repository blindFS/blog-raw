---
layout: post
title: "Fontconfig cheatsheet"
description: ""
category: cheatsheet
tags: font linux wine
---
{% include JB/setup %}

## Synopsis from documents

* `fc-list` show all known fontconfig fonts in various formats

### Fonts configuration files

* files
{% highlight text %}
/etc/fonts/fonts.conf
/etc/fonts/fonts.dtd
/etc/fonts/conf.d
$XDG_CONFIG_HOME/fontconfig/conf.d
$XDG_CONFIG_HOME/fontconfig/fonts.conf
~/.fonts.conf.d
~/.fonts.conf
{% endhighlight %}

#### Font properties

|Property       |Type   |Description                                       |
|---------------|-------|--------------------------------------------------|
|family         |String |Font family names                                 |
|familylang     |String |Languages corresponding to each family            |
|style          |String |Font style. Overrides weight and slant            |
|stylelang      |String |Languages corresponding to each style             |
|fullname       |String |Font full names (often includes style)            |
|fullnamelang   |String |Languages corresponding to each fullname          |
|slant          |Int    |Italic, oblique or roman                          |
|weight         |Int    |Light, medium, demibold, bold or black            |
|size           |Double |Point size                                        |
|width          |Int    |Condensed, normal or expanded                     |
|aspect         |Double |Stretches glyphs horizontally before hinting      |
|pixelsize      |Double |Pixel size                                        |
|spacing        |Int    |Proportional, dual-width, monospace or charcell   |
|foundry        |String |Font foundry name                                 |
|antialias      |Bool   |Whether glyphs can be antialiased                 |
|hinting        |Bool   |Whether the rasterizer should use hinting         |
|hintstyle      |Int    |Automatic hinting style                           |
|verticallayout |Bool   |Use vertical layout                               |
|autohint       |Bool   |Use autohinter instead of normal hinter           |
|globaladvance  |Bool   |Use font global advance data (deprecated)         |
|file           |String |The filename holding the font                     |
|index          |Int    |The index of the font within the file             |
|ftface         |FT_Face|Use the specified FreeType face object            |
|rasterizer     |String |Which rasterizer is in use (deprecated)           |
|outline        |Bool   |Whether the glyphs are outlines                   |
|scalable       |Bool   |Whether glyphs can be scaled                      |
|scale          |Double |Scale factor for point->pixel conversions         |
|dpi            |Double |Target dots per inch                              |
|rgba           |Int    |unknown, rgb, bgr, vrgb, vbgr,                    |
|none - subpixel|geometr|                                                  |
|lcdfilter      |Int    |Type of LCD filter                                |
|minspace       |Bool   |Eliminate leading from line spacing               |
|charset        |CharSet|Unicode chars encoded by the font                 |
|lang           |String |List of RFC-3066-style languages this             |
|font supports  |       |                                                  |
|fontversion    |Int    |Version number of the font                        |
|capability     |String |List of layout capabilities in the font           |
|embolden       |Bool   |Rasterizer should synthetically embolden the font |
|fontfeatures   |String |List of the feature tags in OpenType to be enabled|
|prgname        |String |String Name of the running program                |

* hintstyle:
    * Hintstyle is the amount of font reshaping done to line up to the grid
    1. hintnone
    2. hintslight(prefered in most situations)
    3. hintmedium
    4. hintfull

#### Font matching

* fontconfig performs matching by *measuring the distance* from a provided pattern to all of the available fonts.(always returns a font)
* distance measurement (priority order):
    1. foundry
    2. charset
    3. family
    4. lang,
    5. spacing
    6. pixelsize
    7. style
    8. slant
    9. weight
    10. antialias
    11. rasterizer
    12. outline
* match/edit sequences
    1. modify how fonts are selected; aliasing families and suitable defaults
    2. modify how the selected fonts are rasterized
* example

{% highlight xml %}
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match>
        <test qual="any" name="family">
            <string>宋体</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>SimSun</string>
        </edit>
    </match>
</fontconfig>
{% endhighlight %}

#### Font names


`<families>-<point sizes>:<name1>=<values1>:<name2>=<values2>...`

#### Debugging applications


* `FC_DEBUG=value application`
* values:

|Name       | Value  | Meaning                                        |
|-----------|--------|------------------------------------------------|
|MATCH      |     1  | Brief information about font matching          |
|MATCHV     |     2  | Extensive font matching information            |
|EDIT       |     4  | Monitor match/test/edit execution              |
|FONTSET    |     8  | Track loading of font information at startup   |
|CACHE      |    16  | Watch cache files being written                |
|CACHEV     |    32  | Extensive cache file writing information       |
|PARSE      |    64  | (no longer in use)                             |
|SCAN       |   128  | Watch font files being scanned to build caches |
|SCANV      |   256  | Verbose font file scanning information         |
|MEMORY     |   512  | Monitor fontconfig memory usage                |
|CONFIG     |  1024  | Monitor which config files are loaded          |
|LANGSET    |  2048  | Dump char sets used to construct lang values   |
|OBJTYPES   |  4096  | Display message when value typechecks fail     |

#### File format

* &lt;fontconfig&gt;
    * &lt;dir prefix="default"&gt;: a directory name which will be scanned for font files to include in the set of available fonts
    * &lt;cachedir prefix="default"&gt;: a directory name that is supposed to be stored or read the acache of font information
    * &lt;include ignore_missing="no" prefix="default"&gt;: the name of an additional configuration file or directory
    * &lt;match&gt;
    * &lt;alias&gt;: shorthand notation for the set of common match operations needed to substitue one font family for another
{% highlight xml %}
<alias>
    <family>Times</family>
    <prefer>
        <family>Times New Roman</family>
    </prefer>
    <default>
        <family>serif</family>
    </default>
</alias>
{% endhighlight %}
* &lt;test qual="qual" name="property" target="default" compare="compare"&gt;
* &lt;edit name="property" mode="mode" binding="binding"&gt;

|Mode              | With Match             | Without Match          |
|------------------|------------------------|------------------------|
|"assign"          | Replace matching value | Replace all values     |
|"assign_replace"  | Replace all values     | Replace all values     |
|"prepend"         | Insert before matching | Insert at head of list |
|"prepend_first"   | Insert at head of list | Insert at head of list |
|"append"          | Append after matching  | Append at end of list  |
|"append_last"     | Append at end of list  | Append at end of list  |
|"delete"          | Delete matching value  | Delete all values      |
|"delete_all"      | Delete all values      | Delete all values      |

* example
{% highlight xml %}
<!--
    Names not including any well known alias are given 'sans-serif'
-->
<match target="pattern">
    <test qual="all" name="family" mode="not_eq"><string>sans-serif</string></test>
    <test qual="all" name="family" mode="not_eq"><string>serif</string></test>
    <test qual="all" name="family" mode="not_eq"><string>monospace</string></test>
    <edit name="family" mode="append_last"><string>sans-serif</string></edit>
</match>
<match>
    <test name="lang" compare="contains">
        <string>zh</string>
    </test>
    <test name="family"><string>serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
        <string>Palatino</string>
        <string>Palatino Linotype</string>
        <string>Times New Roman</string>
        <string>Times</string>
        <string>FZShuSong-Z01</string>
        <string>STSong</string>
        <string>SimSun</string>
    </edit>
</match>
{% endhighlight %}

* ...

## My rendering preference

{% highlight xml %}
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <!-- ##Style: osx2 -->
    <!-- ******************************************************************  -->
    <!-- ******************* BASE RENDERING SETTINGSS  ********************  -->
    <!-- ******************************************************************  -->

    <!-- These are the base settings for all rendered fonts.
    We modify them for specific fonts later. -->

    <match target="font">
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="autohint" mode="assign">
            <bool>false</bool>
        </edit>
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
        <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
        </edit>
    </match>

    <!--disable hint for awesome wm-->
    <match target="font">
        <test name="prgname" compare="contains">
            <string>awesome</string>
        </test>
        <edit name="hintstyle" mode="assign">
            <const>hintnone</const>
        </edit>
    </match>

</fontconfig>
{% endhighlight %}

## Font configuration for wine(crossover)

Most applications started by wine prefer to use SimSun. I hate SimSun (especially in wine).
It' OK if I force it to replace all occurrence of SimSun to sth else on my system using fontconfig.
However there is a simpler way, just by changing some of the registries of wine and all SimSun in wined programs will be replaced.

1. find `Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes`
2. create new string value, "SimSun"="SimHei" or something similar
