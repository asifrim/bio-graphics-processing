# 
# = bio/graphics/panel - panel class
#
# Copyright::   Copyright (C) 2007, 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
#               Charles Comstock <dgtized@gmail.com>
# License::     The Ruby License
#
include Math

# = DESCRIPTION
# The Bio::Graphics set of objects allow for creating simple images that
# display features on a linear map. A picture consists of:
# * one *panel*: container of all tracks
# * one or more *tracks*: container of the features. Multiple tracks
#   can exist in the same graphic to allow for differential visualization of
#   different feature types (e.g. genes as blue rectangles and polymorphisms
#   as red triangles)
# * one or more *features* in each track: these are the actual features that
#   you want to display (e.g. 'gene 1', 'SNP 123445')
# * a *ruler* on top of the panel: is added automatically
#
# Schematically:
#  panel
#    +-> track 1
#    |     +-> feature 1
#    |     +-> feature 2
#    |     +-> feature 3
#    +-> track 2
#    |     +-> feature 4
#    |     +-> feature 5
#    +-> ruler
#
# = USAGE
#   # Create a panel for something with a length of 653. This could be a
#   # sequence of 653 bp, but also a genetic map of 653 cM.
#   g = Bio::Graphics::Panel.new(653)
#
#   # Add the first track (e.g. 'genes')
#   track1 = g.add_track('genes')
#
#   # And put features in that track
#   track1.add_feature('gene1','250..375')
#   track1.add_feature('gene2','54..124')
#   track1.add_feature('gene3','100..500')
#
#   # Add a second track (e.g. 'polymorphisms')
#   track2 = g.add_track('polymorphisms', false, [1,0,0], :triangle)
#
#   # And put features on this one
#   track2.add_feature('polymorphism 1','56')
#   track2.add_feature('polymorphism 2','103')
#
#   # Create the actual image as SVG text
#   g.draw('my_picture.png')
# 
# = NOTE ON ARGUMENTS
# As there can be an overwhelming number of arguments for some methods in 
# Bio::Graphics, any optional arguments have to be provided as a hash. For
# example: the Track#add_feature method has only one mandatory argument (the
# feature object) and several optional ones. This is how you can use that 
# method:
#   track.add_feature(my_feature_object,
#                     :label => 'anonymous',
#                     :link => 'http://www.google.com',
#                     :glyph => :box,
#                     :colour => [0,1,0]
#                    )
module Bio::Graphics

  # The defaults
  DEFAULT_PANEL_WIDTH = 800  # How many pixels wide do we want the picture to be?
  TRACK_HEADER_HEIGHT = 12   # The track header will contain the title.
  FEATURE_HEIGHT = 10        # The height in pixels of a glyph.
  FEATURE_V_DISTANCE = 5     # The vertical distance in pixels between glyphs
  FEATURE_ARROW_LENGTH = 5   # In pixels again.
  FONT = ['Georgia', 1, 1]

  # The Bio::Graphics::Panel class describes the complete graph and contains
  # all tracks. See Bio::Graphics documentation for explanation of interplay
  # between different classes.
  class Bio::Graphics::Panel
    # Create a new Bio::Graphics::Panel object
    #
    #   g = Bio::Graphics::Panel.new(456)
    #
    # The height of the image is calculated automatically depending on how many
    # tracks and features it contains. The width of the image defaults to 800 pt
    # but can be set manually by using the width argument to the opts hash:
    #
    #   g = Bio::Graphics::Panel.new(456, :width => 1200)
    #
    #
    # See also: Bio::Graphics::Panel::Track,
    # Bio::Graphics::Panel::Track::Feature
    # ---
    # *Arguments*:
    # * _length_ :: length of the thing you want to visualize, e.g for
    #   visualizing a sequence that is 3.24 kb long, use 324. (required)
    # * _:width_ :: width of the resulting image in pixels. (default: 800)
    # * _:clickable_ :: whether the picture should have clickable glyphs or not
    #   (default: false) If set to true, a html file will be created with
    #   the map.
    # * _:display_start_ :: start coordinate to be displayed (default: 1)
    # * _:display_stop_ :: stop coordinate to be displayed (default: length of sequence)
    # * _:vertical_ :: Boolean: false = horizontal (= default)
    # * _:format_ :: File format of the picture. Can be :png, :svg, :pdf or :ps
    #   (default: :png)
    # *Returns*:: Bio::Graphics::Panel object
    def initialize(length, opts = {})
      @length = length
      opts = {
        :width => DEFAULT_PANEL_WIDTH,
        :display_range => Range.new(0,@length),
        :vertical => false,
        :clickable => false,
      }.merge(opts)
      
      @width = opts[:width].to_i

      @display_range = opts[:display_range]
      @display_start = [0, @display_range.lend].max
      @display_stop = [@length,@display_range.rend].min
      if @display_stop <= @display_start
        raise "[ERROR] Start coordinate to be displayed has to be smaller than stop coordinate."
      end
      @display_range = Range.new(@display_start,@display_stop)
      
      @vertical = opts[:vertical]
      @clickable = opts[:clickable]
      
      @format = opts[:format]
      if @format && ! [:png, :tga, :tif, :jpeg].include?(@format)
        raise "[ERROR] Format has to be one of :png, :tga, :tif, :jpeg."
      end
      
      @tracks = Array.new
      @number_of_feature_rows = 0
      @image_map = ImageMap.new

      @rescale_factor = (@display_stop - @display_start).to_f / @width
      
      # To prevent that we do the whole drawing thing multiple times
      @final_panel_destination = nil
    end
    attr_accessor :length, :width, :height, :rescale_factor, :tracks, :number_of_feature_rows, :clickable, :image_map, :display_start, :display_stop, :display_range, :vertical, :format, :final_panel_destination

    # Adds a Bio::Graphics::Track container to this panel. A panel contains a
    # logical grouping of features, e.g. (for sequence annotation:) genes,
    # polymorphisms, ESTs, etc.
    #
    #  est_track = g.add_track('ESTs', :label => false, :glyph => :directed_generic)
    #  gene_track = g.add_track('genes', :label => true)
    #
    # ---
    # *Arguments*:
    # * _name_ :: Name to be displayed at the top of the track. (Required)
    # * _:label_ :: boolean. Whether or not to display the labels for the features.
    #   (Default = true)
    # * _:glyph_ :: Default glyph for features in this track. For more info, see
    #   the lib/bio/graphics/glyph directory. (Default = :generic)
    # * _:colour_ :: Default colour for features in this track, in RGB
    #   (Default = [0,0,1])
    # *Returns*:: Bio::Graphics::Track object that has just been created
    def add_track(name, opts = {})
      track = Bio::Graphics::Track.new(self, name, opts)
      @tracks.push(track)
      return track
    end

    def draw
      plot = Trackplot.new()
      plot.render_panel(self)
    end

  


  end #Panel
end #Graphics
