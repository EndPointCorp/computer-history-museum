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
fdata = {}
gdata = {}
jfile = File.read(ARGV[0])#.to_json
gdata = JSON.parse(jfile)

# gdata.first
# {"pk"=>64, "model"=>"geo.bookmark", "fields"=>{"flytoview"=>"<LookAt><longitude>-122.0363057013695</longitude><latitude>37.416416435228484</latitude><range>195.98463958043783</range><altitude>21.885370183054878</altitude><heading>159.46928862274004</heading><tilt>62.25604035126786</tilt><range>195.98463958043783</range><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>", "description"=>"", "group"=>1, "slug"=>"lockheed-martin", "title"=>"1932: Lockheed Martin"}}

# Iniitiate gx:Tour and FlyTo for each abstract view

# Get audio duration
audio_duration = []
f = File.open("durations.txt","r")
f.each_line do | line |
    audio_duration << {:seconds => line.to_f}
end


fdata = gdata.first.fetch("fields")

flyto = fdata.fetch("flytoview")
desc = fdata.fetch("description")
group = fdata.fetch("group")
title = fdata.fetch("title")

puts "Title: #{title}"

#exit

# Remove last element of points[]
gdata.pop

gdata.each do |p, v|
  # {"pk", "model", "fields(hash)"} 

  #fdata = JSON.parse(p.fetch("fields").to_json)

  #fdata = p.fetch("fields")

  flyto = p.fetch("fields").fetch("flytoview")
  desc = p.fetch("fields").fetch("description")
  group = p.fetch("fields").fetch("group")
  title = p.fetch("fields").fetch("title")

 # flyto = p.fetch("fields").has_key?("flytoview")
 # desc = p.fetch("fields").has_key?("description")
 # group = p.fetch("fields").has_key?("group")
 # title = p.fetch("fields").has_key?("title")

 # puts "flytoview: #{flyto}"
 # puts "desc: #{desc}"
 # puts "group: #{group}"
 # puts "title: #{title}"
 # puts

  # [ flytoview, description, group, slug, title ]
  points << { :flyto => flyto, :desc => desc, :group => group, :title => title }

end

# Set standard view
std_view = points.last[:flyto]

# Built tours for each point
i = 0
points.each do |p,v|

    # name the Document using the data filename
    name_document = "#{p[:title]} FlyTo"
    tourname = name_document.gsub(':','').gsub(' ','-').downcase
    
    Document.new "#{name_document}"

    # Create an AutoPlay folder with the Autoplay networklink
    name_folder 'AutoPlay'
    get_folder << Kamelopard::NetworkLink.new( URI::encode("http://localhost:8765/query.html?query=playtour=#{tourname}"), {:name => "Autoplay", :flyToView => 0, :refreshVisibility => 0} )

    # Name the Tour element using the data filename
    name_tour     "#{tourname}"

    # Process XML :flyto
    xml_str = p[:flyto]
    puts xml_str

    # Convert to Placemark String
    xml_plmrk_str = "<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\"><Document><Placemark>#{xml_str}</Placemark><Placemark>#{std_view}</Placemark></Document></kml>"
    # Create XML Document
    xml_doc = XML::Parser.string(xml_plmrk_str).parse
    #each_placemark(XML::Document.file("#{xml_plmrk_str}")) do |p,v|
    
    place = []
    modifyView=true
    each_placemark(xml_doc) do |m,n|
        if modifyView
            # override abstract_views
            puts "...overriding view"
            n[:tilt] = 67.67
            n[:range] = 97.67
            modifyView=false
        end
        place << n
    end

    puts place

    puts "...returing to overview"
    puts "Building tour: #{tourname}"

    # fly to overview
    fly_to make_view_from(place.last), :duration => 1.5

    # pause
    pause 0.5

    # pause
    dur = audio_duration[i][:seconds].to_i + 2
    rest = dur / 2

    # fly to location
    fly_to make_view_from(place.first), :duration => rest

    puts "...resting for: #{rest}"
    pause rest 

    # output to the same name as the data file, except with .kml extension
    outfile = [ tourname, 'kml' ].join('.')
    write_kml_to outfile
    i += 1
end

