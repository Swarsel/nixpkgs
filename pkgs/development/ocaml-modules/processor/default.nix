{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "processor";
  version = "0.1-unstable-2024-07-23";

  src = fetchFromGitHub {
    owner = "haesbaert";
    repo = "ocaml-processor";
    rev = "74df5ab38773e5c4ad5c3a3f21f525d863731c17";
    hash = "sha256-tWmgAsYfcpZUyxo7F+WIC3WOfAjDiuV74CscqEd93gk=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "CPU topology and affinity for ocaml-multicore";
    homepage = "https://haesbaert.github.io/ocaml-processor/processor/index.html";
    changelog = "https://github.com/haesbaert/ocaml-processor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://github.com/haesbaert/ocaml-processor";
  };
})
