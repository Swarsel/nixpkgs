{
  lib,
  fetchurl,
  buildDunePackage,
  lwt,
  ssl,
}:

buildDunePackage (finalAttrs: {
  pname = "lwt_ssl";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/ocsigen/lwt_ssl/releases/download/${finalAttrs.version}/lwt_ssl-${finalAttrs.version}.tbz";
    hash = "sha256-swIK0nrs83fhw/J0Cgizbcu6mR+EMGZRE1dBBUiImnc=";
  };

  propagatedBuildInputs = [
    ssl
    lwt
  ];

  duneVersion = "3";

  meta = {
    description = "OpenSSL binding with concurrent I/O";
    homepage = "https://github.com/aantron/lwt_ssl";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
