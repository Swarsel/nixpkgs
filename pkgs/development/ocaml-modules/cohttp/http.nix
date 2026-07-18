{
  buildDunePackage,
  cohttp,
  ppx_expect,
}:

buildDunePackage {
  inherit (cohttp)
    version
    src
    ;

  pname = "http";
  propagatedBuildInputs = [ ppx_expect ];
  minimalOCamlVersion = "5.1";

  meta = cohttp.meta // {
    description = "CoHTTP implementation using the Lwt concurrency library";
  };
}
