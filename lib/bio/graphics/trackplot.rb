
DEFAULT_PANEL_WIDTH = 800  # How many pixels wide do we want the picture to be?
TRACK_HEADER_HEIGHT = 12   # The track header will contain the title.
FEATURE_HEIGHT = 10        # The height in pixels of a glyph.
FEATURE_V_DISTANCE = 5     # The vertical distance in pixels between glyphs
FEATURE_ARROW_LENGTH = 5   # In pixels again.
FONT = ['Georgia', 1, 1]

class Trackplot < Processing::App
  load_libraries 'bio-graphics-processing'

  # Create the drawing
  #--
  # The fact that display_start and display_stop can be set has two
  # consequences:
  #  1. not all features are drawn
  #  2. the x-coordinate of all glyphs has to be corrected
  #++
  def render_panel(panel)
    #Run through the rendering process once to determine the final dimensions
    paneldump = Marshal.dump(panel)
    paneltest = Marshal.load(paneldump)
    vertical_offset = 0
    ruler = Bio::Graphics::Ruler.new(panel)
    self.render_ruler(ruler)
    vertical_offset += ruler.height

    # Add tracks
    paneltest.tracks.each do |track|
      track.vertical_offset = vertical_offset
      self.render_track(track)
      paneltest.number_of_feature_rows += track.number_of_feature_rows
      vertical_offset += ( track.number_of_feature_rows*(FEATURE_HEIGHT+FEATURE_V_DISTANCE+5)) + 10 # '10' is for the header
    end
    #resize the image
    paneltest.height = ruler.height
    paneltest.height += 20*paneltest.number_of_feature_rows
    paneltest.height += 10*paneltest.tracks.length #To correct for the track headers
    self. frame.set_resizable(true)
    self.frame.set_size(paneltest.width,paneltest.height+20)
    self.size(paneltest.width,paneltest.height+20)

     if panel.vertical
        #@image_map.flip_orientation(@width)

        self.size(paneltest.height,paneltest.width)
        self.rotate(3*PI/2)
        panel.height, panel.width = panel.width, panel.height
        #rotated_destination = Cairo::ImageSurface.new(1, max_size, max_size)
        #rotated_context = Cairo::Context.new(rotated_destination)
        #rotated_context.rotate(3*PI/2)
        #rotated_context.translate(-@width, 0)
        #rotated_context.set_source(huge_panel_destination, 0, 0)
        #rotated_context.rectangle(0,0,max_size, max_size).fill
        @width, @height = @height, @width
      end
    #start the rendering process anew
    vertical_offset = 0
    ruler = Bio::Graphics::Ruler.new(panel)
    self.render_ruler(ruler)
    vertical_offset += ruler.height

    # Add tracks
    panel.tracks.each do |track|
      track.vertical_offset = vertical_offset
      self.render_track(track)
      panel.number_of_feature_rows += track.number_of_feature_rows
      vertical_offset += ( track.number_of_feature_rows*(FEATURE_HEIGHT+FEATURE_V_DISTANCE+5)) + 10 # '10' is for the header
    end
    
    filename = File.basename($0).gsub!(/.rb/,'')
    if panel.format
      case panel.format
      when :png
        self.save_frame(filename+".png")
      when :tga
        self.save_frame(filename+".tga")
      when :tif
        self.save_frame(filename+".tif")
      when :jpeg
        self.save_frame(filename+".jpeg")
      end
      #exit
    end
  end


     
#
#      @final_panel_destination = Cairo::ImageSurface.new(1, @width, @height)
#      resized_context = Cairo::Context.new(@final_panel_destination)
#      resized_context.set_source(huge_panel_destination, 0, 0)
#      resized_context.rectangle(0,0,@width, @height).fill
#    end
#
    
#
#
#    if @clickable # create png and map
#      html_filename = file_name.sub(/\.[^.]+$/, '.html')
#      html = File.open(html_filename,'w')
#      html.puts "<html>"
#      html.puts "<body>"
#      html.puts @image_map.to_s
#      html.puts "<img border='1' src='" + file_name + "' usemap='#image_map' />"
#      html.puts "</body>"
#      html.puts "</html>"
#      html.close
#    end


def render_ruler(ruler)
  self.stroke(0)
  self.stroke_weight(2)
  # Draw line
  self.line(0,10,ruler.panel.width,10)
  # Draw ticks
  #  * And start drawing the rest.
  ruler.first_tick_position.step(ruler.panel.display_stop, ruler.minor_tick_distance) do |tick|
    tick_pixel_position = (tick - ruler.panel.display_start) / ruler.panel.rescale_factor
    if tick.modulo(ruler.major_tick_distance) == 0
      self.line(tick_pixel_position.floor, 5, tick_pixel_position.floor, 3*ruler.tick_height)

      # Draw tick number
      self.fill(0)
      self.text_font(@myfontsmall)
      self.text(tick.to_i.to_s,tick_pixel_position.floor, 4*ruler.tick_height + ruler.tick_text_height)
    else
      self.line(tick_pixel_position.floor, 10, tick_pixel_position.floor, ruler.tick_height)

    end
  end
end

# Adds the track to a cairo drawing. This method should not be used
# directly by the user, but is called by Bio::Graphics::Panel.draw
# ---
# *Arguments*:
# * _panel__drawing_ (required) :: the panel cairo object
# *Returns*:: FIXME: I don't know
def render_track(track)

  self.stroke(0.8,0.8,0.8)
  self.line(0, track.vertical_offset,track.panel.width, track.vertical_offset)

  # Draw track title
  self.fill(0,0,0)
  self.text_font(@myfont)
  self.text(track.name,0,Bio::Graphics::TRACK_HEADER_HEIGHT + track.vertical_offset + 10)

  # Draw the features
  track.features.sort_by{|f| f.start}.each do |feature|
    # Don't even bother if the feature is not in the view
    if feature.stop <= track.panel.display_start or feature.start >= track.panel.display_stop
      next
    else
      self.render_feature(feature)
    end
  end

  track.number_of_feature_rows = ( track.grid.keys.length == 0 ) ? 1 : track.grid.keys.max + 1

end

# Adds the feature to the track cairo context. This method should not
# be used directly by the user, but is called by
# Bio::Graphics::Track.draw
# ---
# *Arguments*:
# * _track_drawing_ (required) :: the track cairo object
# *Returns*:: FIXME: I don't know
def render_feature(feature)

  # Move the feature drawing down based on track it's in and the number
  # of times is has to be bumped
  row = feature.find_row

  feature.vertical_offset = feature.track.vertical_offset + Bio::Graphics::TRACK_HEADER_HEIGHT + Bio::Graphics::FEATURE_V_DISTANCE
  feature.vertical_offset += (Bio::Graphics::FEATURE_HEIGHT+Bio::Graphics::FEATURE_V_DISTANCE)*row

  # Let the subfeatures do the drawing.
  feature.subfeatures.each do |subfeature|
    self.render_subfeature(subfeature)
  end

  feature.left_pixel_of_feature = feature.left_pixel_of_subfeatures.min
  feature.right_pixel_of_feature = feature.right_pixel_of_subfeatures.max

  # Add the label for the feature
  if feature.track.show_label
    text_range = feature.start.floor..(feature.start.floor + self.text_width(feature.label)*feature.track.panel.rescale_factor)
    if feature.track.grid[row+1].nil?
      feature.track.grid[row+1] = Array.new
    end
    feature.track.grid[row].push(text_range)
    feature.track.grid[row+1].push(text_range)
    self.fill(0)
    self.text_font(@myfontsmall)
    self.text(feature.label,feature.left_pixel_of_feature, feature.vertical_offset+20)
  end

  #FIXME Uncomment and adapt this!
  # And add the region to the image map
  #    # Comment: we have to add the vertical_offset and TRACK_HEADER_HEIGHT!
  #    @track.panel.image_map.add_element(@left_pixel_of_feature,
  #      @vertical_offset,
  #      @right_pixel_of_feature,
  #      @vertical_offset + Bio::Graphics::FEATURE_HEIGHT,
  #      @link
  #    )
end
def render_subfeature(subfeature)
  # Set some parameters at draw time instead of initialization.
  # Set the glyph to be used. The glyph can be set as a symbol (e.g. :generic)
  # or as a hash (e.g. {'utr' => :line, 'cds' => :directed_spliced}).
  if subfeature.feature.glyph.class == Hash
    subfeature.glyph = subfeature.feature.glyph[subfeature.feature_object.feature]
  else
    subfeature.glyph = subfeature.feature.glyph
  end

  if subfeature.feature.colour.class == Hash
    subfeature.colour = subfeature.feature.colour[subfeature.feature_object.feature]
  else
    subfeature.colour = subfeature.colour.nil? ? subfeature.feature.colour : subfeature.colour
  end
  subfeature.colour = subfeature.colour.respond_to?(:call) ? subfeature.colour.call(self) : subfeature.colour

  # We have to check if we want to change the glyph type from directed to
  # undirected
  # There are 2 cases where we don't want to draw arrows on
  # features:
  # (a) when the picture is really zoomed out, features are
  # so small that the arrow itself is too big
  # (b) if a directed feature on the fw strand extends beyond
  # the end of the picture, the arrow is out of view. This
  # is the same as considering the feature as undirected.
  # The same obviously goes for features on the reverse
  # strand that extend beyond the left side of the image.
  #
  # (a) Zoomed out
  replace_directed_with_undirected = false
  if (subfeature.stop - subfeature.start).to_f/subfeature.feature.track.panel.rescale_factor.to_f < 2
    replace_directed_with_undirected = true
  end
  # (b) Extending beyond borders picture
  if ( subfeature.chopped_at_stop and subfeature.strand = 1 ) or ( subfeature.chopped_at_start and subfeature.strand = -1 )
    replace_directed_with_undirected = true
  end

  local_feature_glyph = nil
  if subfeature.glyph == :directed_generic and replace_directed_with_undirected
    local_feature_glyph = :generic
  elsif subfeature.glyph == :directed_spliced and replace_directed_with_undirected
    local_feature_glyph = :spliced
  elsif subfeature.glyph == :directed_box and replace_directed_with_undirected
    local_feature_glyph = :box
  else
    local_feature_glyph = subfeature.glyph
  end

  # And draw the thing.
  glyph_name = 'Bio::Graphics::Glyph::' + local_feature_glyph.to_s.camel_case
  glyph_class = glyph_name.to_class
  glyph = glyph_class.new(subfeature)
  glyph.render(self)

  subfeature.feature.left_pixel_of_subfeatures.push(glyph.left_pixel)
  subfeature.feature.right_pixel_of_subfeatures.push(glyph.right_pixel)


end

def setup
  size(2000,2000)
  background(255,255,255)
  color_mode(Processing::App::RGB,1.0)
  @myfont = create_font("ProggyClean",12)
  @myfontsmall = create_font("ProggyClean",9)
  text_font(@myfont)
end



end