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
      panel.no_fill
      colour = self.subfeature.colour.clone
      panel.stroke(colour.shift,colour.shift,colour.shift)
      panel.stroke_weight(2)
      #rgb = panel.rescalergb(self.subfeature.colour)
      #panel.stroke(rgb.shift,rgb.shift,rgb.shift)
      panel.rect(self.left_pixel, self.subfeature.feature.vertical_offset, (self.right_pixel - self.left_pixel), Bio::Graphics::FEATURE_HEIGHT)
      

    end
  end
end
