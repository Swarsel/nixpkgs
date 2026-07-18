{
  lib,
  fetchurl,
  buildDunePackage,
  re,
  stdlib-shims,
  uuidm,
}:

buildDunePackage (finalAttrs: {
  pname = "redis";
  version = "0.8";

  src = fetchurl {
    url = "https://github.com/0xffea/ocaml-redis/releases/download/v${finalAttrs.version}/redis-${finalAttrs.version}.tbz";
    hash = "sha256-Cli30Elur3tL/0bWK6PBBy229TK4jsQnN/0oVQux01I=";
  };

  propagatedBuildInputs = [
    re
    stdlib-shims
    uuidm
  ];

  doCheck = true;
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Redis client";
    homepage = "https://github.com/0xffea/ocaml-redis";
    license = lib.licenses.bsd3;
  };
})
