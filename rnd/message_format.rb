require 'nokogiri'
require 'pry'

fix_xml_path = '/Users/richardn/Downloads/quickfixj/core/src/main/resources/FIX43.xml'
xml = Nokogiri.parse(File.open(fix_xml_path, 'r') { |f| f.read })

def read_field(xml_element, field_mappings)
  if xml_element.name != 'group'
    { name: xml_element['name'], 
      required: xml_element['required'] == 'Y', 
      number: field_mappings[xml_element['name']]
    }
  else
    {
      group: xml_element['name'], 
      required: xml_element['required'] == 'Y',
      fields: xml_element.children.select { |e| e.is_a?(Nokogiri::XML::Element) }.map { |e| read_field(e, field_mappings) }
    }
  end
end

field_ids = xml.xpath('/fix/fields/field').map do |f|
              name = 
              result = {number: f['number'].to_i, type: f['type']}
              if !f.children.empty?
                values = []
                f.children.select { |e| e.is_a?(Nokogiri::XML::Element)}.each do |ce|
                  values << {value: ce['enum'], description: ce['description']}
                end
                result[:values] = values
              end
              [f['name'], f['number'].to_i]
            end
field_mappings = Hash[field_ids]

header_fields = xml.xpath('//header/*').map { |e| read_field(e, field_mappings)}
trailer_fields = xml.xpath('//trailer/*').map { |e| read_field(e, field_mappings)}
messages = xml.xpath('//messages/*').map do |m|
             fields = m.children.select { |e| e.is_a?(Nokogiri::XML::Element) }.map { |e| read_field(e, field_mappings) }
             details = {
                         type: m['msgtype'],
                         category: m['msgcat'],
                         fields: [header_fields + fields + trailer_fields].flatten
                       }
             [m['name'].to_sym, details]
           end
messages = Hash[messages]
components = xml.xpath('//components/*').map do |m|
               {
                 name: m['name'].to_sym,
                 fields: m.children.select { |e| e.is_a?(Nokogiri::XML::Element) }.map { |e| read_field(e, field_mappings) }
               }
             end
pp messages[:MarketDataIncrementalRefresh]