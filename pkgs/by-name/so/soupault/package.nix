{
  lib,
  stdenv,
  darwin,
  fetchzip,
  ocaml,
  ocamlPackages,
  removeReferencesTo,
  soupault,
  testers,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "soupault";
  version = "5.3.0";

  src = fetchzip {
    hash = "sha256-HrvLQQdjTISMO+9KPhRuEGyajFaOLGEevnaGUYzgz6M=";

    urls = [
      "https://github.com/PataphysicalSociety/soupault/archive/${finalAttrs.version}.tar.gz"
      "https://codeberg.org/PataphysicalSociety/soupault/archive/${finalAttrs.version}.tar.gz"
    ];
  };

  nativeBuildInputs = [
    removeReferencesTo
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.sigtool
  ];

  buildInputs = with ocamlPackages; [
    base64
    camomile
    cmarkit
    containers
    csv
    digestif
    ezjsonm
    fileutils
    fmt
    jingoo
    lambdasoup
    lua-ml
    logs
    markup
    odate
    otoml
    re
    spelll
    tsort
    yaml
  ];

  postFixup = ''
    find "$out" -type f -exec remove-references-to -t ${ocaml} '{}' +
  '';

  minimalOCamlVersion = "5.3";

  passthru.tests.version = testers.testVersion {
    command = "soupault --version-number";
    package = soupault;
  };

  meta = {
    description = "Tool that helps you create and manage static websites";
    homepage = "https://soupault.app/";
    changelog = "https://codeberg.org/PataphysicalSociety/soupault/src/branch/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ toastal ];
    mainProgram = "soupault";
  };
})
