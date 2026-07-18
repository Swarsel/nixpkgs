{
  lib,
  fetchFromGitHub,
  bdffont,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "pcffont";
  version = "0.0.25";

  src = fetchFromGitHub {
    owner = "TakWolf";
    repo = "pcffont";
    tag = version;
    hash = "sha256-xxTOw7Fdey5YKDY1kq3EiAjW2jNHIU3wFDKvHdPgAQc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  dependencies = [ bdffont ];
  pyproject = true;
  pythonImportsCheck = [ "pcffont" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library for manipulating Portable Compiled Format (PCF) Fonts";
    homepage = "https://github.com/TakWolf/pcffont";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];

    platforms = lib.platforms.all;
  };
}
