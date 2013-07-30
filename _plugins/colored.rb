module Jekyll
class ColoredTag< Liquid::Tag
    Syntax = /^\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}|rgb[a]{0,1}\([ .0-9,]{5,}\))\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}|rgb[a]{0,1}\([ .0-9,]{5,}\))?\s*"([^"]*)"\s*$/
    def initialize(tagName, markup, tokens)
        if markup =~ Syntax then
            @bg = $1
            if $3.nil? then
                @fg = "#ffffff"
                @text = $2
            else
                @fg = $2
                @text = $3
            end
        else
            raise "Invalid colors"
        end
    end
    def render(context)
        "<div style=\"display: inline;background-color:#{@bg};color:#{@fg}\">#{@text}</div>"
    end
    Liquid::Template.register_tag('colored', Jekyll::ColoredTag)
end
end
