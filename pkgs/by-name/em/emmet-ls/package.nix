{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchpatch,
}:

buildNpmPackage rec {
  pname = "emmet-ls";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "aca";
    repo = "emmet-ls";
    rev = version;
    hash = "sha256-TmsJpVLF9FZf/6uOM9LZBKC6S3bMPjA3QMiRMPaY9Dg=";
  };

  patches = [
    # update package-lock.json as it is outdated
    (fetchpatch {
      hash = "sha256-/3ZbOBxScnfhL1F66cnIoD2flVeYTJ2sLxNHQ9Yrgjw=";
      name = "fix-lock-file-to-match-package-json.patch";
      url = "https://github.com/aca/emmet-ls/commit/111111a2c2113f751fa12a716ccfbeae61c32079.patch";
    })
  ];

  npmDepsHash = "sha256-Boaxkad7S6H+eTW5AHwBa/zj/f1oAGGSsmW1QrzuFWc=";

  meta = {
    description = "Emmet support based on LSP";
    homepage = "https://github.com/aca/emmet-ls";
    changelog = "https://github.com/aca/emmet-ls/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "emmet-ls";
  };
}
