{
  buildDunePackage,
  faraday-lwt-unix,
  gluten,
  gluten-lwt,
  lwt_ssl,
}:

buildDunePackage {
  inherit (gluten)
    doCheck
    meta
    src
    version
    ;

  pname = "gluten-lwt-unix";

  propagatedBuildInputs = [
    faraday-lwt-unix
    gluten-lwt
    lwt_ssl
  ];
}
