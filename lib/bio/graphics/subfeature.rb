# 
# = bio/graphics/subfeature.rb - subfeature class
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
# 

# TODO: Documentation for SubFeature
class Bio::Graphics::SubFeature
  # !!Not to be used directly.
  # ---
  # *Arguments*:
  # * _feature_ (required) :: Bio::Graphics::Feature
  #   object that this subfeature belongs to
  # * _feature_ _object_ (required) :: A Bio::Feature object (see bioruby)
  # * :glyph :: Glyph to use. Default = glyph of the track
  # * :colour :: Colour. Default = colour of the track
  # *Returns*:: Bio::Graphics::SubFeature object
  def initialize(feature, feature_object, opts = {})
    @feature = feature
    @feature_object = feature_object
    opts = {
      :glyph => @feature.glyph,
      :colour => @feature.colour
    }.merge(opts)
    
    @glyph = opts[:glyph]
    @colour = opts[:colour]
    @colour ||= [1,0,0]
    @locations = @feature_object.locations

    @start = @locations.collect{|l| l.from}.min.to_i
    @stop = @locations.collect{|l| l.to}.max.to_i
    @strand = @locations[0].strand.to_i
    @pixel_range_collection = Array.new
    @chopped_at_start = false
    @chopped_at_stop = false
    @hidden_subfeatures_at_start = false
    @hidden_subfeatures_at_stop = false

    # Get all pixel ranges for the subfeatures
    @locations.each do |l|
      #   xxxxxx  [          ]
      if l.to < @feature.track.panel.display_start
        @hidden_subfeatures_at_start = true
        next
      #           [          ]   xxxxx
      elsif l.from > @feature.track.panel.display_stop
        @hidden_subfeatures_at_stop = true
        next
      #      xxxx[xxx       ]
      elsif l.from < @feature.track.panel.display_start and l.to > @feature.track.panel.display_start
        start_pixel = 1
        stop_pixel = ( l.to - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        @chopped_at_start = true
      #          [      xxxx]xxxx
      elsif l.from < @feature.track.panel.display_stop and l.to > @feature.track.panel.display_stop
        start_pixel = ( l.from - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        stop_pixel = @feature.track.panel.width
        @chopped_at_stop = true
      #      xxxx[xxxxxxxxxx]xxxx
      elsif l.from < @feature.track.panel.display_start and l.to > @feature.track.panel.display_stop
        start_pixel = 1
        stop_pixel = @feature.track.panel.width
        @chopped_at_start = true
        @chopped_at_stop = true
      #          [   xxxxx  ]
      else
        start_pixel = ( l.from - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
        stop_pixel = ( l.to - @feature.track.panel.display_start ).to_f / @feature.track.panel.rescale_factor
      end

      @pixel_range_collection.push(Range.new(start_pixel, stop_pixel))

    end
  end

  # The bioruby Bio::Feature object
  attr_accessor :feature_object

  # The feature that this subfeature belongs to
  attr_accessor :feature

  # The label of the feature
  attr_accessor :label
  alias :name :label

  # The locations of the feature (which is a Bio::Locations object)
  attr_accessor :locations
  alias :location :locations

  # The start position of the feature (in bp)
  attr_accessor :start

  # The stop position of the feature (in bp)
  attr_accessor :stop

  # The strand of the feature
  attr_accessor :strand

  # The glyph to use to draw this (sub)feature
  attr_accessor :glyph

  # The colour to use to draw this (sub)feature
  attr_accessor :colour

  # The array keeping the pixel ranges for the sub-features. Unspliced
  # features will just have one element, while spliced features will
  # have more than one.
  attr_accessor :pixel_range_collection

  # Is the first subfeature incomplete?
  attr_accessor :chopped_at_start

  # Is the last subfeature incomplete?
  attr_accessor :chopped_at_stop

  # Are there subfeatures out of view at the left side of the picture?
  attr_accessor :hidden_subfeatures_at_start

  # Are there subfeatures out of view at the right side of the picture?
  attr_accessor :hidden_subfeatures_at_stop

  # Adds the subfeature to the track cairo context. This method should not 
  # be used directly by the user, but is called by
  # Bio::Graphics::Feature::SubFeature.draw
  # ---
  # *Arguments*:
  # * _track_drawing_ (required) :: the track cairo object
  # *Returns*:: FIXME: I don't know
  
end #SubFeature
