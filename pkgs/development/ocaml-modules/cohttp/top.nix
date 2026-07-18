{ buildDunePackage, cohttp }:

buildDunePackage {
  inherit (cohttp) version src;
  pname = "cohttp-top";
  propagatedBuildInputs = [ cohttp ];
  doCheck = true;

  meta = cohttp.meta // {
    description = "CoHTTP toplevel pretty printers for HTTP types";
  };
}
