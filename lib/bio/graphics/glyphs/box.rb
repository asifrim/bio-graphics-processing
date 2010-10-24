# 
# = bio/graphics/glyphs/box - box glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Box < Bio::Graphics::Glyph::Common
    def render(panel)
      panel.fill(255,255,255)
      panel.stroke(255,0,0)
      panel.rect(self.left_pixel, self.subfeature.feature.vertical_offset, (self.right_pixel - self.left_pixel), Bio::Graphics::FEATURE_HEIGHT)
      

    end
  end
end
