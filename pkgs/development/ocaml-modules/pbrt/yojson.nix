{
  base64,
  buildDunePackage,
  pbrt,
  yojson,
}:

buildDunePackage {
  inherit (pbrt) version src;
  pname = "pbrt_yojson";

  propagatedBuildInputs = [
    pbrt
    base64
    yojson
  ];

  meta = pbrt.meta // {
    description = "Runtime library for ocaml-protoc to support JSON encoding/decoding";
  };
}
