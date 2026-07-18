{
  lib,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pandoc-mustache";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "michaelstepner";
    repo = "pandoc-mustache";
    tag = version;
    hash = "sha256-lgbQV4X2N4VuIEtjeSA542yqGdIs5QQ7+bdCoy/aloE=";
  };

  build-system = with python3Packages; [
    setuptools
    pyparsing
  ];

  dependencies = with python3Packages; [
    panflute
    pystache
    pyyaml
    future
  ];

  pyproject = true;

  passthru = {
    tests = callPackage ./tests { };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pandoc Mustache Filter";
    homepage = "https://github.com/michaelstepner/pandoc-mustache";
    changelog = "https://github.com/michaelstepner/pandoc-mustache/releases/tag/${version}/CHANGELOG.md";

    license = with lib.licenses; [
      cc-by-10
    ];

    maintainers = with lib.maintainers; [ averdow ];
  };
}
