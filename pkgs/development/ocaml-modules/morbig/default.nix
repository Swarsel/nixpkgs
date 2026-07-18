{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
  menhirLib,
  ocaml,
  ppx_deriving_yojson,
  visitors,
}:

buildDunePackage (finalAttrs: {
  pname = "morbig";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "colis-anr";
    repo = "morbig";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fOBaJHHP/Imi9UDLflI52OdKDcmMxpl+NH3pfofmv/o=";
  };

  # Compatibility with menhir ≥ 20260122
  patches = [ ./menhir.patch ];

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    menhirLib
    ppx_deriving_yojson
    visitors
  ];

  meta = {
    description = "Static parser for POSIX Shell";
    homepage = "https://github.com/colis-anr/morbig";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ niols ];
    broken = lib.versionAtLeast ocaml.version "5.4";
  };
})
