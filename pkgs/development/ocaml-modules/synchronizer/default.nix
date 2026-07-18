{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  prelude,
}:

buildDunePackage (finalAttrs: {
  pname = "synchronizer";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "synchronizer";
    tag = finalAttrs.version;
    hash = "sha256-zomP15CRV6pFK3yk9hMCSDHPk11hEqXiRw8vr2Dg0CI=";
  };

  propagatedBuildInputs = [
    prelude
  ];

  checkInputs = [
    alcotest
  ];

  minimalOCamlVersion = "5.2";

  meta = {
    description = "Synchronizer to make datastructures thread-safe";
    homepage = "https://github.com/OCamlPro/synchronizer";
    changelog = "https://raw.githubusercontent.com/OCamlPro/synchronizer/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ redianthus ];
  };
})
