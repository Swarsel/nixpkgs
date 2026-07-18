{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "appimage";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ssh-mitm";
    repo = "appimage";
    tag = finalAttrs.version;
    hash = "sha256-aL0JcA6R2FUMcXykbXaSaUEz1ERs3iKh4c0cbRAClSY=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "appimage" ];

  meta = {
    description = "AppImage start scripts";
    homepage = "https://github.com/ssh-mitm/appimage";
    changelog = "https://github.com/ssh-mitm/appimage/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
