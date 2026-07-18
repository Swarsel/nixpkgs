{
  buildDunePackage,
  conduit-mirage,
  faraday-lwt,
  gluten,
  gluten-lwt,
  mirage-flow,
}:

buildDunePackage {
  inherit (gluten) src version;
  pname = "gluten-mirage";

  propagatedBuildInputs = [
    gluten-lwt
    faraday-lwt
    conduit-mirage
    mirage-flow
  ];

  meta = gluten.meta // {
    description = "Mirage support for gluten";
  };
}
