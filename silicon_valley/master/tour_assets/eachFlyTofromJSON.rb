#!/usr/bin/env ruby
# vim:ts=4:sw=4:et:smartindent:nowrap
require 'kamelopard'
require 'json'

include Kamelopard

# data filename should be the first argument ./me ./path/to/data-file
data_filename = File.basename(ARGV[0],'.*')

# Collect points from data file

points = []

# Read JSON
gdata = {}
jfile = File.read(ARGV[0])#.to_json
gdata = JSON.parse(jfile)

# gdata.first
# {"pk"=>64, "model"=>"geo.bookmark", "fields"=>{"flytoview"=>"<LookAt><longitude>-122.0363057013695</longitude><latitude>37.416416435228484</latitude><range>195.98463958043783</range><altitude>21.885370183054878</altitude><heading>159.46928862274004</heading><tilt>62.25604035126786</tilt><range>195.98463958043783</range><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>", "description"=>"", "group"=>1, "slug"=>"lockheed-martin", "title"=>"1932: Lockheed Martin"}}

# Iniitiate gx:Tour and FlyTo for each abstract view
gdata.each do |p|
  # {"pk", "model", "fields(hash)"} 
  n = 0
  m = 0
  fdata = p.fetch('fields')
  fdata.each do |q|
    # [ flytoview, description, group, slug, title ]
    q.each do |x|
      # [ [flytoview, <LookAt>...], [description, ""], [group, 1], [slug, $slug], [title, $title] ]
      # Do We Care About it? 
      if n == 1  # Yes, we do
        case m
          when 0
            flyto = x
          when 3
            slug = x
          when 4
            title = x
          else
        end
        # Populate points[]
        points << { :flyto => flyto, :slug => slug, :title => title }
      else
       # No, we don't
      end
      m = m + 1
    end
    n = 1
  end
end

# Built tours for each point
points.each do |p,v|

    # name the Document using the data filename
    name_document = "#{p[:name].capitalize} FlyTo"
    tourname = name_document.gsub(' ','-').downcase
    
    Document.new "#{name_document}"

    # Create an AutoPlay folder with the Autoplay networklink
    name_folder 'AutoPlay'
    get_folder << Kamelopard::NetworkLink.new( URI::encode("http://localhost:81/change.php?query=playtour=#{tourname}\&amp;name=#{name_document}"), {:name => "Autoplay", :flyToView => 0, :refreshVisibility => 0} )

    # Name the Tour element using the data filename
    name_tour     "#{tourname}"

    # fly to each point
    fly_to make_view_from(p), :duration => 6

    # pause
    pause 2

    # output to the same name as the data file, except with .kml extension
    outfile = [ tourname, 'kml' ].join('.')
    write_kml_to outfile
end

