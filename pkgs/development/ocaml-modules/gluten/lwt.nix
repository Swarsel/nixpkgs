{
  buildDunePackage,
  gluten,
  lwt,
}:

buildDunePackage {
  inherit (gluten)
    doCheck
    meta
    src
    version
    ;

  pname = "gluten-lwt";

  propagatedBuildInputs = [
    gluten
    lwt
  ];
}
