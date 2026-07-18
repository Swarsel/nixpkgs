{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  cmdliner,
  fetchpatch,
  gitUpdater,
  ppx_deriving,
  ppxlib,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_deriving_cmdliner";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "hammerlab";
    repo = "ppx_deriving_cmdliner";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/22KLQnxu3e2ZSca6ZLxTJDfv/rsmgCUkJnZC0RwRi8";
  };

  patches = [
    # Ppxlib.0.26.0 compatibility
    # remove when a new version is released
    (fetchpatch {
      sha256 = "sha256-FfUfEAsyobwZ99+s5sFAaCE6Xgx7jLr/q79OxDbGcvQ=";
      url = "https://patch-diff.githubusercontent.com/raw/hammerlab/ppx_deriving_cmdliner/pull/50.patch";
    })
  ];

  propagatedBuildInputs = [
    cmdliner
    ppx_deriving
    ppxlib
    result
  ];

  doCheck = true;

  checkInputs = [
    (alcotest.override { inherit cmdliner; })
  ];

  minimalOCamlVersion = "4.11";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Ppx_deriving plugin for generating command line interfaces from types for OCaml";
    homepage = "https://github.com/hammerlab/ppx_deriving_cmdliner";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.romildo ];
    broken = lib.versionAtLeast ppxlib.version "0.36";
  };
})
