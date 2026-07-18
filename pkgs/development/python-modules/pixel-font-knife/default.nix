{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pypng,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  unidata-blocks,
  uv-build,
}:

buildPythonPackage rec {
  pname = "pixel-font-knife";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "pixel-font-knife";
    tag = version;
    hash = "sha256-f4jaLEPXl8oo1olWBeymMn5a8Tyl07h1TW4pZ5OItZU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];

  dependencies = [
    pypng
    unidata-blocks
    pyyaml
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "pixel_font_knife" ];

  meta = {
    description = "Set of pixel font utilities";
    homepage = "https://github.com/TakWolf/pixel-font-knife";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];

    platforms = lib.platforms.all;
  };
}
