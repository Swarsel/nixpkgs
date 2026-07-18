{
  lib,
  buildDunePackage,
  cppo,
  fetchzip,
  findlib,
  ocaml,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "malfunction";
  version = "0.7.1";

  src = fetchzip {
    url = "https://github.com/stedolan/malfunction/archive/refs/tags/v${finalAttrs.version}.tar.gz";
    hash = "sha256-Cpe5rSBvsr3pqbucGZelutPoI+bcQPFCbdcKsE/HieY=";
  };

  nativeBuildInputs = [
    cppo
  ];

  propagatedBuildInputs = [
    findlib
    zarith
  ];

  meta = {
    description = "Malfunction is a high-performance, low-level untyped program representation, designed as a target for compilers of functional programming languages.";
    homepage = "http://github.com/stedolan/malfunction";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ _4ever2 ];
    mainProgram = "malfunction";
    broken = lib.versionAtLeast ocaml.version "5.4";
  };
})
