{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  # propagatedBuildInputs,
  charon,
  core_unix,
  domainslib,
  nix-update-script,
  ocamlgraph,
  ppx_deriving_yojson,
  progress,
  visitors,
}:

buildDunePackage (finalAttrs: {
  inherit (charon) version;
  pname = "aeneas";

  src = fetchFromGitHub {
    owner = "AeneasVerif";
    repo = "aeneas";
    tag = "nightly-${finalAttrs.version}";
    hash = "sha256-uQAGj3moRftf1OWIuzfRoFsO/tv0Hhx3X/8qRU0yOqk=";
  };

  propagatedBuildInputs = [
    charon
    core_unix
    domainslib
    ocamlgraph
    ppx_deriving_yojson
    progress
    visitors
  ];

  # The test suite consists of heavy integration tests that require the full
  # toolchain (Rust, charon and the F*/Coq/Lean backends), so it is not run here.
  doCheck = false;
  __structuredAttrs = true;
  minimalOCamlVersion = "5.1";
  sourceRoot = "${finalAttrs.src.name}/src";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

  meta = {
    description = "Verification toolchain for Rust programs";
    homepage = "https://github.com/AeneasVerif/aeneas";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.all;
    mainProgram = "aeneas";
  };
})
