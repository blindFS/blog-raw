class XiaMi < Liquid::Tag
    Syntax = /^\s*(\d+_\d+)\s*/
    def initialize(tagName, markup, tokens)
        super
        if markup =~ Syntax then
        @id = $1
        else
            raise "Illgeal ID presented."
        end
    end
    def render(context)
        "<embed src=\"http://www.xiami.com/widget/#{@id}/singlePlayer.swf\" type=\"application/x-shockwave-flash\" width=\"257\" height=\"33\" wmode=\"transparent\"></embed>"
    end
    Liquid::Template.register_tag "xiami", self
end
