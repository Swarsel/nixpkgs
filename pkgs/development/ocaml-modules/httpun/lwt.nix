{
  buildDunePackage,
  gluten,
  gluten-lwt,
  httpun,
  lwt,
}:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-lwt";

  propagatedBuildInputs = [
    gluten
    gluten-lwt
    httpun
    lwt
  ];

  meta = httpun.meta // {
    description = "Lwt support for httpun";
  };
}
