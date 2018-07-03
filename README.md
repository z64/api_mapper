# api_mapper

This is a proof of concept shard for developing object mappings for JSON APIs
in an automated fashion.

The idea is to use a pull parser to interpret the API response into an ECR
template that generates a struct mapped with `JSON::Serializable`.

## Usage

At the moment, something like this should work:

```crystal
require "api_mapper"

# Get a response from somewhere
response = HTTP::Client.get("https://some-service/api/resource/1")

File.open("resource.cr") do |io|
  template = APIMapper::ObjectTemplate.from_json(response.body, "Resource")
  template.to_s(io)
end
```

Imagining the response is something like:

```json
{
  "foo": 1,
  "bar": "bar",
  "array": [1, 2, 3],
  "object": {"foo": "bar"}
}
```

`resource.cr` will now contain:

```crystal
struct Resource
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
```

- The raw value of that key is written in a comment following the property, so
  that you can review it afterwards and maybe change it to a more accurate type.

- A `JSON::Field` annotation is provided with `key`, as the most common
  correction from an API response you might make for use in Crystal-space is
  giving the property a more appropriate name. The line can be left, or removed
  if you don't need it.

## Status

There's lots of things this doesn't support yet, but it shows its possible and
probably very useful in getting a head start in mapping very large API responses.

- More JSON types should be covered
- For `:begin_object`, we could parse this again into *another* `ObjectTemplate`
  and defer its output to output a full mapping for a nested object.

If this is useful to you, please feel free to PR! This was just an experiment
and I may or may not keep developing it in my free time.
