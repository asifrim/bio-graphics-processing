# 
# = bio/graphics/glyphs/generic - generic glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Generic < Bio::Graphics::Glyph::Common
    def render(panel)
      panel.no_stroke
      colour = self.subfeature.colour.clone
      panel.fill(colour.shift,colour.shift,colour.shift)
      panel.rect(self.left_pixel, self.subfeature.feature.vertical_offset, (self.right_pixel - self.left_pixel), Bio::Graphics::FEATURE_HEIGHT)
    end
  end
end
