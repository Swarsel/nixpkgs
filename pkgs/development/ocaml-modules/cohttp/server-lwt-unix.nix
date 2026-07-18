{
  buildDunePackage,
  cohttp,
  cohttp-lwt-unix,
  http,
  lwt,
}:

buildDunePackage (finalAttrs: {
  inherit (cohttp) version src;
  pname = "cohttp-server-lwt-unix";

  propagatedBuildInputs = [
    http
    lwt
  ];

  doCheck = true;
  checkInputs = [ cohttp-lwt-unix ];

  meta = cohttp.meta // {
    description = "Lightweight Cohttp + Lwt based HTTP server";
  };
})
