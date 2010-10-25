# 
# = bio/graphics/feature.rb - feature class
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
# 

# The Bio::Graphics::Feature class describes features to be
# placed on the graph. See Bio::Graphics documentation for explanation
# of interplay between different classes.
#
# The position of the Feature is a Bio::Locations object to make it possible
# to transparently work with simple and spliced features.
#
# The Bio::Graphics::Feature class inherits from Bio::Feature.
class Bio::Graphics::Feature
  # !!Not to be used directly. Use
  # Bio::Graphics::Track.add_feature instead!!
  # A feature can not exist except within the confines of a
  # Bio::Graphics::Track object.
  #
  #--
  # This is necessary because the feature needs to know the colour and glyph,
  # both of which are defined within the panel.
  #++
  #
  # ---
  # *Arguments*:
  # * _track_ (required) :: Bio::Graphics::Track object that this
  #   feature belongs to
  # * _feature_ _object_ (required) :: A Bio::Feature object (see bioruby)
  # * _:label_ :: Label of the feature. Default = 'anonymous'
  # * _:link_ :: URL for clickable images. Default = nil
  # * _:glyph_ :: Glyph to use. Default = glyph of the track
  # * _:colour_ :: Colour. Default = colour of the track
  # *Returns*:: Bio::Graphics::Feature object
  def initialize(track, feature_object, opts = {})
    @track = track
    @feature_object = feature_object
    opts = {
      :label => 'anonymous',
      :link => nil,
      :glyph => @track.glyph,
      :colour => @track.colour
    }.merge(opts)
    
    @label = opts[:label]
    @link = opts[:link]
    @glyph = opts[:glyph]
    @colour = opts[:colour] || @track.colour
    
    @locations = @feature_object.locations

    @start = @locations.collect{|l| l.from}.min.to_i
    @stop = @locations.collect{|l| l.to}.max.to_i

    # Create Bio::Graphics SubFeatures
    # The drawing is handled by subfeatures. If there are no defined, the
    # subfeatures array will just hold one element: the @feature_object of
    # self.
    @subfeatures = Array.new
    if ! @feature_object.subfeatures.empty?
      @feature_object.subfeatures.each do |subfeature|
        @subfeatures.push(Bio::Graphics::SubFeature.new(self, subfeature, :glyph => @glyph, :colour => @colour))
      end
    else
      @subfeatures.push(Bio::Graphics::SubFeature.new(self, @feature_object, :glyph => @glyph, :colour => @colour))
    end

    @left_pixel_of_subfeatures = Array.new
    @right_pixel_of_subfeatures = Array.new
  end

  # The bioruby Bio::Feature object
  attr_accessor :feature_object

  attr_accessor :locations

  # The Bio::Graphics SubFeatures
  attr_accessor :subfeatures

  # The track that this feature belongs to
  attr_accessor :track

  # The label of the feature
  attr_accessor :label
  alias :name :label

  # The URL to be followed when the glyph for this feature is clicked
  attr_accessor :link

  # The glyph to use to draw this (sub)feature
  attr_accessor :glyph

  # The colour to use to draw this (sub)feature
  attr_accessor :colour

  attr_accessor :start, :stop
  attr_accessor :left_pixel_of_feature, :top_pixel_of_feature, :right_pixel_of_feature
  attr_accessor :left_pixel_of_subfeatures, :right_pixel_of_subfeatures
  
  attr_accessor :vertical_offset

  

  # Calculates the row within the track where this feature should be
  # drawn. This method should not 
  # be used directly by the user, but is called by
  # Bio::Graphics::Feature.draw
  # ---
  # *Arguments*:: none
  # *Returns*:: row number
  def find_row
    row_found = false

    # We've got to find out what row to draw the feature on. If two 
    # features overlap, one of them has to be 'bumped' down. So we'll
    # first try to draw a new feature at the top of the track. If
    # it however would overlap with another one, we'll bump it down
    # to the next row.
    feature_range = (@start.floor - 1..@stop.ceil + 1)
    row = 1
    row_available = true
    until row_found
      if ! @track.grid[row].nil?
        @track.grid[row].each do |covered|
          if feature_range.include?(covered.first) or covered.include?(feature_range.first)
            row_available = false
          end
        end
        if ! @track.grid[row+1].nil? #Still have to check if there is no label there.
          @track.grid[row+1].each do |covered|
            if feature_range.include?(covered.first) or covered.include?(feature_range.first)
              row_available = false
            end
          end
        end
      end

      if ! row_available
        row += 1
        row_available = true
      else # We've found the place where to draw the feature.
        if @track.grid[row].nil?
          @track.grid[row] = Array.new
        end
        @track.grid[row].push(feature_range)
        row_found = true
      end
    end
    return row
  end
     
end #Feature
