# 
# = bio/graphics/glyphs/directed_spliced - directed_spliced glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedSpliced < Bio::Graphics::Glyph::Common
    def render(panel)
      panel.no_stroke
      colour = self.subfeature.colour.clone
      panel.fill(colour.shift,colour.shift,colour.shift)
      gap_starts = Array.new
      gap_stops = Array.new

      #   Start with the one with the arrow
      pixel_ranges = self.subfeature.pixel_range_collection.sort_by{|pr| pr.lend}
      range_with_arrow = nil
      if self.subfeature.strand == -1 # reverse strand => box with arrow is first one
        range_with_arrow = pixel_ranges.shift
        panel.rect((range_with_arrow.lend)+Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        arrow(panel,:left,range_with_arrow.lend+Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset ,Bio::Graphics::FEATURE_ARROW_LENGTH)
      else # forward strand => box with arrow is last one
        range_with_arrow = pixel_ranges.pop
        panel.rect(range_with_arrow.lend, self.subfeature.feature.vertical_offset, range_with_arrow.rend - range_with_arrow.lend - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        arrow(panel,:right,range_with_arrow.rend-Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset,Bio::Graphics::FEATURE_ARROW_LENGTH)
      end
      gap_starts.push(range_with_arrow.rend)
      gap_stops.push(range_with_arrow.lend)

      #   And then add the others
      draw_spliced(panel, pixel_ranges, gap_starts, gap_stops)

    end
  end
end


