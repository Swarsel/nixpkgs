{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "minisat";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "ocaml-minisat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dH0Ndlyo/DTZ6Ao1S478aBuxoZFSkRBi5HblkTWCPas=";
  };

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_COMPILE = "-I${lib.getInclude stdenv.cc.libcxx}/include/c++/v1";
  };

  minimalOCamlVersion = "4.05";

  meta = {
    description = "Simple bindings to Minisat-C";
    homepage = "https://c-cube.github.io/ocaml-minisat/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ mgttlinger ];
  };
})
