{
  lib,
  fetchFromGitHub,
  bdffont,
  brotli,
  buildPythonPackage,
  fonttools,
  nix-update-script,
  pcffont,
  pypng,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "pixel-font-builder";
  version = "0.0.47";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "pixel-font-builder";
    tag = version;
    hash = "sha256-a25JKZy5XaBfpeFwH7YnSTY28hQF8dLa/AGEOXHN94I=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];

  dependencies = [
    fonttools
    brotli
    bdffont
    pcffont
    pypng
  ];

  pyproject = true;
  pythonImportsCheck = [ "pixel_font_builder" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library that helps create pixel style fonts";
    homepage = "https://github.com/TakWolf/pixel-font-builder";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];

    platforms = lib.platforms.all;
  };
}
