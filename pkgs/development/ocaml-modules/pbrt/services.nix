{
  buildDunePackage,
  pbrt,
  pbrt_yojson,
}:

buildDunePackage {
  inherit (pbrt) version src;
  pname = "pbrt_services";

  propagatedBuildInputs = [
    pbrt
    pbrt_yojson
  ];

  meta = pbrt.meta // {
    description = "Runtime library for ocaml-protoc to support RPC services";
  };
}
