{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ament-package";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "ament";
    repo = "ament_package";
    tag = finalAttrs.version;
    hash = "sha256-4NLrRcBM82Bu8hDufma3z5li/kJQCyJEJma0UBBBvKw=";
  };

  # Tests currently broken
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "ament_package" ];
  # The script selects tag release-alpha8
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Parser for the manifest files in the ament buildsystem";
    homepage = "https://github.com/ament/ament_package";
    changelog = "https://github.com/ament/ament_package/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
})
