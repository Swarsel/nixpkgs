{
  lib,
  fetchurl,
  buildDunePackage,
  eio,
  ssl,
}:

buildDunePackage (finalAttrs: {
  pname = "eio-ssl";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/anmonteiro/eio-ssl/releases/download/${finalAttrs.version}/eio-ssl-${finalAttrs.version}.tbz";
    hash = "sha256-m4CiUQtXVSMfLthbDsAftpiOsr24I5IGiU1vv7Rz8go=";
  };

  propagatedBuildInputs = [
    eio
    ssl
  ];

  meta = {
    description = "OpenSSL binding to EIO";
    homepage = "https://github.com/anmonteiro/eio-ssl";
    license = lib.licenses.lgpl21;
  };
})
