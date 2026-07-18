{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "epaper-dithering";
  version = "5.0.9";

  src = fetchFromGitHub {
    owner = "OpenDisplay";
    repo = "epaper-dithering";
    tag = "epaper-dithering-v${finalAttrs.version}";
    hash = "sha256-JG+UXE4T9HbjESGLzLjUhvYfqWwPHq+b+dENjq3eQrA=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-KXEDtl4k08jco8sG7cS9yM3iJkKWKZNF5Fb9+wHxhyc=";
  };

  dependencies = [
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "epaper_dithering" ];
  sourceRoot = "${finalAttrs.src.name}/packages/python";

  meta = {
    description = "Dithering algorithms for e-paper/e-ink displays";
    homepage = "https://github.com/OpenDisplay/epaper-dithering";
    changelog = "https://github.com/OpenDisplay/epaper-dithering/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
