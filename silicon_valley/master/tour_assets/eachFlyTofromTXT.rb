#!/usr/bin/env ruby
#require 'rubygems'
require 'kamelopard'
require 'open-uri'
#require 'nokogiri'
#require 'csv'
#require 'json'

include Kamelopard
#include Kameloaprd::Functions

file="./queries.txt"

# data filename should be the first argument ./me ./path/to/data-file
#data_filename = File.basename(ARGV[0],'.*')

# Build data from file
geodata = []
f = File.open("#{file}","r")
f.each_line do | line |
    query = line.split("@")
    geodata << {:planet => query[0], :name => query[1], :flytoview => query[2].sub("flytoview=","").chomp}
end

# Build Tours per Location
geodata.each do | geo |
    # Skip Location if not earth
    next unless geo[:planet] == "earth"
    # Continue building tour
    puts "Building Tour..."
    gname = geo[:name]
    name_doc = gname
    tourname = "#{gname} Tour"
    file_name = gname.sub(" ","-").downcase
    #tour_doc = Kamelopard::Document.new "#{name_doc}", :filename => file_name

    Document.new "#{name_doc}"

    # ISpaces Autoplay
    name_folder 'AutoPlay'
    get_folder << Kamelopard::NetworkLink.new( URI::encode("http://localhost:9001/query.html?query=playtour=#{tourname}"), {:name => "Autoplay", :flyToView => 0, :refreshVisibility => 0} )

    name_tour   "#{tourname}"

    # fly to each point
    # Process XML :flyto
    xml_str = geo.fetch(:flytoview)
    # Convert to Placemark String
    xml_plmrk_str = "<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\"><Document><Placemark>#{xml_str}</Placemark></Document></kml>"
    # Create XML Document
    xml_doc = XML::Parser.string(xml_plmrk_str).parse
    #each_placemark(XML::Document.file("#{xml_plmrk_str}")) do |p,v|

    points = []
    each_placemark(xml_doc) do |p,v|
        points << v
    end

    #each_placemark(XML::Document.file(ARGV[0])) do |p,v|
    #fly_to make_view_from(geo[:flytoview]), :duration => 5
    #fly_to xml_doc, :duration => 5
    #fly_to make_view_from(xml_str), :duration => 4
    
    points.each do | flyto |

        fly_to make_view_from(flyto), :duration => 4

        # pause
        pause 2

        # Process XML :flyto
        #xml_str = geo.fetch(:flytoview)
        # Convert to Placemark String
        #xml_plmrk_str = "<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\"><Document><Placemark>#{xml_str}</Placemark></Document></kml>"
        # Create XML Document
        #xml_doc = XML::Parser.string(xml_plmrk_str).parse
        #fly_to make_view_from(geo[:flytoview]), :duration => 5
        #fly_to xml_doc, :duration => 5
        #pause 2    

        #p = point(flyto[:longitude], flyto[:latitude], flyto[:altitude], :relativeToGround)
        #        orbit( p, flyto[:range], flyto[:tilt], flyto[:heading].to_f, flyto[:heading].to_f + 45, {:duration => 9, :step => 10, :already_there => true} )
        #pause 1
    end

    # output to the same name as the data file, except with .kml extension
    outfile = [ file_name, 'kml' ].join('.')
    puts "Writing #{outfile}..."
    write_kml_to outfile
end

