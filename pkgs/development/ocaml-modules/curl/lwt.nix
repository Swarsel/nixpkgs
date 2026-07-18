{
  lib,
  buildDunePackage,
  curl,
  lwt,
}:

buildDunePackage (finalAttrs: {
  inherit (curl) version src;
  pname = "curl_lwt";

  propagatedBuildInputs = [
    curl
    lwt
  ];

  doCheck = true;

  meta = curl.meta // {
    description = "Bindings to libcurl (lwt variant)";
  };
})
