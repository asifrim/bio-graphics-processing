# 
# = bio/graphics/glyphs/common - common methods for all glyphs
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Common
    def initialize(subfeature)
      @subfeature = subfeature
    end
    attr_accessor :subfeature

    def left_pixel
      if self.class == Bio::Graphics::Glyph::Triangle
        return @subfeature.pixel_range_collection[0].lend - Bio::Graphics::FEATURE_ARROW_LENGTH
      elsif self.class == Bio::Graphics::Glyph::Dot
        return @subfeature.pixel_range_collection[0].lend - @radius
      else
        return @subfeature.pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
      end
    end
    
    def right_pixel
      if self.class == Bio::Graphics::Glyph::Triangle
        return @subfeature.pixel_range_collection[0].rend + Bio::Graphics::FEATURE_ARROW_LENGTH
      elsif self.class == Bio::Graphics::Glyph::Dot
        return @subfeature.pixel_range_collection[0].rend + @radius
      else
        return @subfeature.pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
      end
    end
    
    private

    # Method to draw each of the squared spliced rectangles for
    # spliced and directed_spliced
    # ---
    # *Arguments*:
    # * _track_drawing_::
    # * _pixel_ranges_:: 
    # * _top_pixel_of_feature_:: 
    # * _gap_starts_:: 
    # * _gap_stops_:: 
    def draw_spliced(panel, pixel_ranges, gap_starts, gap_stops)
      p self.subfeature.colour
      rgb = panel.rescalergb(self.subfeature.colour)
      panel.fill(rgb.shift,rgb.shift,rgb.shift)
      # draw the parts
      pixel_ranges.each do |range|
        panel.rect(range.lend, self.subfeature.feature.vertical_offset, range.rend - range.lend, Bio::Graphics::FEATURE_HEIGHT)
        gap_starts.push(range.rend)
        gap_stops.push(range.lend)
      end

      # And then draw the connections in the gaps
      # Start with removing the very first start and the very last stop.
      gap_starts.sort!.pop
      gap_stops.sort!.shift

      gap_starts.length.times do |gap_number|
        connector(panel,gap_starts[gap_number].to_f,gap_stops[gap_number].to_f)
      end

      if self.subfeature.hidden_subfeatures_at_stop
        from = self.subfeature.pixel_range_collection.sort_by{|pr| pr.lend}[-1].rend
        to = self.subfeature.feature.track.panel.width
        panel.line(from, Bio::Graphics::FEATURE_ARROW_LENGTH + self.subfeature.feature.vertical_offset, to, Bio::Graphics::FEATURE_ARROW_LENGTH + self.subfeature.feature.vertical_offset )
      end

      if self.subfeature.hidden_subfeatures_at_start
        from = 1
        to = self.subfeature.pixel_range_collection.sort_by{|pr| pr.lend}[0].lend
        panel.line(from, Bio::Graphics::FEATURE_ARROW_LENGTH + self.subfeature.feature.vertical_offset , to , Bio::Graphics::FEATURE_ARROW_LENGTH+ self.subfeature.feature.vertical_offset)
      end
    end

    # Method to draw the arrows of directed glyphs. Not to be used
    # directly, but called by Feature#draw.
    def arrow(panel,direction,x,y,size)
      panel.no_stroke
      panel.begin_shape
      case direction
      when :right
        panel.vertex(x,y)
        panel.vertex(x+size,y+size)
        panel.vertex(x,y+2*size)
      when :left
        panel.vertex(x,y)
        panel.vertex(x-size,y+size)
        panel.vertex(x,y+2*size)
      when :north
        panel.vertex(x-size,y+size)
        panel.vertex(x,y)
        panel.vertex(x+size,y+size)
      when :south
        panel.vertex(x-size,y-size)
        panel.vertex(x,y)
        panel.vertex(x+size,y-size)
      end
      panel.end_shape()
    end

    # Method to draw the arrows of directed glyphs. Not to be used
    # directly, but called by Feature#draw.
    def open_arrow(panel,direction,x,y,size)
      panel.begin_shape
      case direction
      when :right
        panel.vertex(x,y)
        panel.vertex(x+size,y+size)
        panel.vertex(x,y+2*size)
      when :left
        panel.vertex(x,y)
        panel.vertex(x-size,y+size)
        panel.vertex(x,y+2*size)
      when :north
        panel.vertex(x-size,y+size)
        panel.vertex(x,y)
        panel.vertex(x+size,y+size)
      when :south
        panel.vertex(x-size,y-size)
        panel.vertex(x,y)
        panel.vertex(x+size,y-size)
      end
      panel.end_shape()
    end
    
    # Method to draw the connections (introns) of spliced glyphs. Not to
    # be used directly, but called by Feature#draw.
    def connector(panel,from,to)
      panel.stroke(0)
      panel.stroke_weight(0.5)
      middle = from + ((to - from)/2)
      panel.line(from, self.subfeature.feature.vertical_offset+ 2, middle, self.subfeature.feature.vertical_offset+ 7)
      panel.line(middle, self.subfeature.feature.vertical_offset+7,to, self.subfeature.feature.vertical_offset+2)
    end                    

  end
  
end
