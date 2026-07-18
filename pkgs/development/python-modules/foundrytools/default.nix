{
  lib,
  fetchFromGitHub,
  # dependencies
  afdko,
  buildPythonPackage,
  cffsubr,
  defcon,
  dehinter,
  fonttools,
  # build-system
  setuptools,
  ttfautohint-py,
  ufo-extractor,
  ufo2ft,
  ufolib2,
}:
buildPythonPackage (finalAttrs: {
  pname = "foundrytools";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "ftCLI";
    repo = "FoundryTools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E0sJ/shudZTvkB8be5KsPJDmCoytv2notrrNT9nDF0I=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    afdko
    cffsubr
    defcon
    dehinter
    fonttools
    ttfautohint-py
    ufo-extractor
    ufo2ft
    ufolib2
  ];

  pyproject = true;

  meta = {
    description = "Library for working with fonts in Python";
    homepage = "https://github.com/ftCLI/FoundryTools";
    changelog = "https://github.com/ftCLI/FoundryTools/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      qb114514
    ];
  };
})
