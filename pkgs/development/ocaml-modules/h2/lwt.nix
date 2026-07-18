{
  buildDunePackage,
  gluten-lwt,
  h2,
  lwt,
}:

buildDunePackage {
  inherit (h2) src version;
  pname = "h2-lwt";

  propagatedBuildInputs = [
    lwt
    gluten-lwt
    h2
  ];

  meta = h2.meta // {
    description = "Lwt support for h2";
  };
}
