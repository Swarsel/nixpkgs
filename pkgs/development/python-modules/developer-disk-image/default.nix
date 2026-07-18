{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "developer-disk-image";
  version = "0.2.0";

  # GitHub archive is way too large
  src = fetchPypi {
    inherit version;
    hash = "sha256-21aLIuwznYtWsprptCAjDq4yL+ab50zZn9Dv+w7y4o8=";
    pname = "developer_disk_image";
  };

  # tests connect to github.com
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "developer_disk_image" ];

  meta = {
    description = "Download DeveloperDiskImage ans Personalized images from GitHub";
    homepage = "https://github.com/doronz88/DeveloperDiskImage";
    changelog = "https://github.com/doronz88/DeveloperDiskImage/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "developer_disk_image";
  };
}
