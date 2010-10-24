# 
# = bio/graphics/glyphs/directed_box - directed_box glyph
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#

module Bio::Graphics::Glyph
  class Bio::Graphics::Glyph::DirectedBox < Bio::Graphics::Glyph::Common
    def render(panel)
      if @subfeature.strand == -1 # Reverse strand
        panel.line(self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset, self.right_pixel,self.subfeature.feature.vertical_offset )
        panel.line(self.right_pixel,self.subfeature.feature.vertical_offset,  self.right_pixel,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT )
        panel.line(self.right_pixel,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT,self.left_pixel + Bio::Graphics::FEATURE_ARROW_LENGTH,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT)
        open_arrow(panel,:left,self.left_pixel+Bio::Graphics::FEATURE_ARROW_LENGTH,self.subfeature.feature.vertical_offset,Bio::Graphics::FEATURE_ARROW_LENGTH)
      else #default is forward strand
        panel.line(self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH,self.subfeature.feature.vertical_offset , self.left_pixel, self.subfeature.feature.vertical_offset)
        panel.line(self.left_pixel, self.subfeature.feature.vertical_offset,self.left_pixel,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT)
        panel.line(self.left_pixel,self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT,self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset + Bio::Graphics::FEATURE_HEIGHT)
        open_arrow(panel, :right, self.right_pixel - Bio::Graphics::FEATURE_ARROW_LENGTH, self.subfeature.feature.vertical_offset, Bio::Graphics::FEATURE_ARROW_LENGTH)
      end
    end
  end
end
