require "ecr"
require "json"

module APIMapper
  VERSION = "0.1.0"

  # A single object's property
  record Property,
    name : String,
    type : String,
    value : String

  # A template for a JSON-mapped object
  struct ObjectTemplate
    def initialize(@klass_name : String, @properties : Array(Property))
    end

    def self.new(parser : JSON::PullParser, klass_name : String)
      properties = [] of Property

      case parser.kind
      when :begin_object
        parser.read_object do |key|
          type = nil
          case parser.kind
          when :int
            type = "Int64"
          when :string
            type = "String"
          when :begin_array
            type = "Array(T)"
          when :begin_object
            type = "T"
          else
            raise "Unsupported property type: #{parser.kind}"
          end

          properties << Property.new(key, type.not_nil!, parser.read_raw)
        end
      else
        raise "Unsupported top-level object type: #{parser.kind}"
      end

      new(klass_name, properties)
    end

    def self.from_json(string_or_io, klass_name)
      parser = JSON::PullParser.new(string_or_io)
      new(parser, klass_name)
    end

    ECR.def_to_s "src/template.ecr"
  end
end
