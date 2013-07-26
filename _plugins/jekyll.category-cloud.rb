# Copyright (C) 2011 Anurag Priyam - MIT License

module Jekyll

  class CategoryCloud < Liquid::Tag
    safe = true

    attr_reader :size_min, :size_max, :precision, :unit, :threshold

    def initialize(name, params, tokens)
      # initialize default values
      @size_min, @size_max, @precision, @unit = 70, 170, 0, '%'
      @threshold                              = 1

      # process parameters
      @params = Hash[*params.split(/(?:: *)|(?:, *)/)]
      process_font_size(@params['font-size'])
      process_threshold(@params['threshold'])

      super
    end

    def render(context)
      count = context.registers[:site].categories.map do |name, posts|
        [name, posts.count] if posts.count >= threshold
      end

      # clear nils if any
      count.compact!

      min, max = count.map(&:last).minmax

      weight = count.map do |name, count|
        # logarithmic distribution
        # weight = (Math.log(count) - Math.log(min))/(Math.log(max) - Math.log(min))
        weight = count
        [name, weight]
      end

      weight.sort_by! { rand }

      weight.reduce("") do |html, category|
        name, weight = category
        size = size_min + ((size_max - size_min) * (Math.log(weight) - Math.log(min))/(Math.log(max) - Math.log(min))).to_f
        size = sprintf("%.#{@precision}f", size)
        html << "<li><a style='font-size: #{size}#{unit}' href='/categories.html#' id='#{name}'>#{name}<span>#{weight}</span></a></li>\n"
      end
    end

    private

    def process_font_size(param)
      /(\d*\.{0,1}(\d*)) *- *(\d*\.{0,1}(\d*)) *(%|em|px)/.match(param) do |m|
        @size_min  = m[1].to_f
        @size_max  = m[3].to_f
        @precision = [m[2].size, m[4].size].max
        @unit      = m[5]
      end
    end

    def process_threshold(param)
      /\d*/.match(param) do |m|
        @threshold = m[0].to_i
      end
    end
  end
end

Liquid::Template.register_tag('category_cloud', Jekyll::CategoryCloud)
