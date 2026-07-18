{
  lib,
  buildDunePackage,
  digestif,
  gluten-lwt,
  httpun-ws,
  lwt,
}:

buildDunePackage {
  inherit (httpun-ws) src version;
  pname = "httpun-ws-lwt";

  propagatedBuildInputs = [
    httpun-ws
    lwt
    digestif
    gluten-lwt
  ];

  doCheck = true;

  meta = httpun-ws.meta // {
    description = "Lwt support for httpun-ws";
  };
}
