{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "mem_usage";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-mem_usage";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5tQNsqbiU9oJvKHUjeTo/ST4A0Axc95gdJISLaa9VRM=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.07";

  meta = {
    description = "Cross-platform memory usage information";
    homepage = "https://www.liquidsoap.info/ocaml-mem_usage/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
