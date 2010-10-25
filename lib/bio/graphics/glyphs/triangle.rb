# 
# = bio/graphics/glyphs/triangle - triangle glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::Triangle < Bio::Graphics::Glyph::Common
    def render(panel)
      raise "Start and stop are not the same (necessary if you want triangle glyphs)" if @subfeature.start != @subfeature.stop
      
      arrow(panel,:north, self.left_pixel + Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset, Bio::Graphics::FEATURE_ARROW_LENGTH)
      
    end
  end
end
