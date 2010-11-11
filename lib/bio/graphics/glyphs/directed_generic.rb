# 
# = bio/graphics/glyphs/directed_generic - directed_generic glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedGeneric < Bio::Graphics::Glyph::Common
    def render(panel)
      panel.no_stroke
      colour = self.subfeature.colour.clone
      panel.fill(colour.shift,colour.shift,colour.shift)
      if self.subfeature.strand == -1 # Reverse strand
        panel.rect(self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset, self.right_pixel - self.left_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        arrow(panel,:left,self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH,self.subfeature.feature.vertical_offset,Bio::Graphics::FEATURE_ARROW_LENGTH)
      else #default is forward strand
        panel.rect(self.left_pixel, self.subfeature.feature.vertical_offset, self.right_pixel- self.left_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, Bio::Graphics::FEATURE_HEIGHT)
        arrow(panel,:right,self.right_pixel-Bio::Graphics::FEATURE_ARROW_LENGTH,self.subfeature.feature.vertical_offset,Bio::Graphics::FEATURE_ARROW_LENGTH)
      end
    end
  end
end
