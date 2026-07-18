{
  lib,
  fetchFromGitHub,
  aiosendspin,
  buildPythonPackage,
  mpris-api,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiosendspin-mpris";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "abmantis";
    repo = "aiosendspin-mpris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hOF6rTm0pppk+J7tTVaLDK5C1ofGXz1YU6RVGm92geQ=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiosendspin
    mpris-api
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiosendspin_mpris" ];

  meta = {
    description = "MPRIS integration for aiosendspin";
    homepage = "https://github.com/abmantis/aiosendspin-mpris";
    changelog = "https://github.com/abmantis/aiosendspin-mpris/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
