# 
# = bio/graphics/glyphs/line_with_handles - line_with_handles glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::LineWithHandles < Bio::Graphics::Glyph::Common
    def render(panel)
      colour = self.subfeature.colour.clone
      panel.stroke(colour.shift,colour.shift,colour.shift)
      panel.line(self.left_pixel,Bio::Graphics::FEATURE_ARROW_LENGTH + self.subfeature.feature.vertical_offset,self.right_pixel,Bio::Graphics::FEATURE_ARROW_LENGTH + self.subfeature.feature.vertical_offset)

      panel.stroke(0,0,0)
      arrow(panel,:right,self.left_pixel - 2, self.subfeature.feature.vertical_offset-1,Bio::Graphics::FEATURE_ARROW_LENGTH)
      arrow(panel,:left,self.right_pixel + 2, self.subfeature.feature.vertical_offset-1,Bio::Graphics::FEATURE_ARROW_LENGTH)

    end
  end
end
