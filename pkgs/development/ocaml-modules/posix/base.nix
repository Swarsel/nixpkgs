{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ctypes,
  integers,
}:

buildDunePackage (finalAttrs: {
  pname = "posix-base";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-posix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nBSIuz4WEnESlECdKujEcSxFOcSBFxW1zo7J/lT/lCY=";
  };

  propagatedBuildInputs = [
    ctypes
    integers
  ];

  meta = {
    description = "Base module for the posix bindings";
    homepage = "https://www.liquidsoap.info/ocaml-posix/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
