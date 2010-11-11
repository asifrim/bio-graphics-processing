# 
# = bio/graphics/glyphs/line - line glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Line < Bio::Graphics::Glyph::Common
    def render(panel)
      colour = self.subfeature.colour.clone
      panel.stroke(colour.shift,colour.shift,colour.shift)
      panel.line(self.left_pixel,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_ARROW_LENGTH, self.right_pixel, Bio::Graphics::FEATURE_ARROW_LENGTH+ self.subfeature.feature.vertical_offset)
    end
  end
end
