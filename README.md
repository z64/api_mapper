# api_mapper

This is a proof of concept shard for developing object mappings for JSON APIs
in an automated fashion.

The idea is to use a pull parser to interpret the API response into an ECR
template that generates a struct mapped with `JSON::Serializable`.

## Usage

At the moment, something like this should work:

```crystal
require "api_mapper"

class_name = ARGV[0]
filename = ARGV[1]?

io = if filename
       File.open(filename, "w")
     else
       STDOUT
     end

template = APIMapper::ObjectTemplate.from_json(STDIN, class_name)
template.to_s(io)

io.close if io.is_a?(File)
```

Let's try [httpbin.org's GET](https://httpbin.org/#/HTTP_Methods/get_get):

```
curl \
  -X GET "https://httpbin.org/get?foo=bar" \
  -H "accept: application/json"\
  | ./test Response
```

We'll get on STDOUT:

```crystal
struct Response
  include JSON::Serializable

  @[JSON::Field(key: "args")]
  property args : T # => {"foo":"bar"}

  @[JSON::Field(key: "headers")]
  property headers : T # => {"Accept":"application/json","Connection":"close","Host":"httpbin.org","User-Agent":"curl/7.60.0"}

  @[JSON::Field(key: "origin")]
  property origin : String # => "12.34.456.789"

  @[JSON::Field(key: "url")]
  property url : String # => "https://httpbin.org/get?foo=bar"
end
```

- See [other examples](https://gist.github.com/z64/cdde1e054f83046b2dc67f24daea2030) from [Discord's API](https://discordapp.com/developers/docs/intro)

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
