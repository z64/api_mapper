require "./spec_helper"

module APIMapper
  describe ObjectTemplate do
    it "#to_s" do
      properties = [
        Property.new("foo", "Int32", "1"),
        Property.new("bar", "String", %("bar")),
      ]
      template = ObjectTemplate.new("Foo", properties)

      template.to_s.should eq <<-DOC
      struct Foo
        include JSON::Serializable

        @[JSON::Field(key: "foo")]
        property foo : Int32 # => 1

        @[JSON::Field(key: "bar")]
        property bar : String # => "bar"
      end

      DOC
    end

    it ".new(parser)" do
      json = <<-JSON
      {
        "foo": 1,
        "bar": "bar",
        "array": [1, 2, 3],
        "object": {"foo": "bar"}
      }
      JSON
      template = ObjectTemplate.from_json(json, "Foo")
      template.to_s.should eq <<-DOC
      struct Foo
        include JSON::Serializable

        @[JSON::Field(key: "foo")]
        property foo : Int64 # => 1

        @[JSON::Field(key: "bar")]
        property bar : String # => "bar"

        @[JSON::Field(key: "array")]
        property array : Array(T) # => [1,2,3]

        @[JSON::Field(key: "object")]
        property object : T # => {"foo":"bar"}
      end

      DOC
    end
  end
end
