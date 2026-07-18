{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "character-encoding-utils";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "character-encoding-utils";
    tag = version;
    hash = "sha256-4WaVvr6/d/oePtmwpGJ/D6tv10V/ok9iN4BrqGk97f0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  pyproject = true;
  pythonImportsCheck = [ "character_encoding_utils" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Some character encoding utils";
    homepage = "https://github.com/TakWolf/character-encoding-utils";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];

    platforms = lib.platforms.all;
  };
}
