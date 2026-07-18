{
  buildDunePackage,
  gluten-lwt-unix,
  httpun-lwt,
}:

buildDunePackage {
  inherit (httpun-lwt) version src;
  pname = "httpun-lwt-unix";

  propagatedBuildInputs = [
    httpun-lwt
    gluten-lwt-unix
  ];

  meta = httpun-lwt.meta // {
    description = "Lwt + Unix support for httpun";
  };
}
