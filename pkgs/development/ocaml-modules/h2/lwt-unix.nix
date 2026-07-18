{
  buildDunePackage,
  faraday-lwt-unix,
  gluten-lwt-unix,
  h2,
  h2-lwt,
}:

buildDunePackage {
  inherit (h2) src version;
  pname = "h2-lwt-unix";

  propagatedBuildInputs = [
    gluten-lwt-unix
    faraday-lwt-unix
    h2-lwt
  ];

  meta = h2.meta // {
    description = "Lwt Unix support for h2";
  };
}
