# 
# = bio/graphics/glyphs/dot - dot glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Dot < Bio::Graphics::Glyph::Common
    attr_accessor :radius
    
    def render(panel)
      raise "Start and stop are not the same (necessary if you want triangle glyphs)" if self.subfeature.start != self.subfeature.stop
      colour = self.subfeature.colour.clone
      panel.no_stroke
      panel.fill(colour.shift,colour.shift,colour.shift)
      @radius = Bio::Graphics::FEATURE_HEIGHT/2
      panel.ellipse(self.left_pixel + @radius, self.subfeature.feature.vertical_offset+ @radius, @radius, @radius)
    end
  end
end