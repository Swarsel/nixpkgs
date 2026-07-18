{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  ward,
}:

buildPythonPackage rec {
  pname = "linuxpy";
  version = "0.23.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-q3gPUJL8M1krSjcPZokmMNxE+g1WLWFJYP4g6Q5/APc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  # Checks depend on WARD testing framework which is broken
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    ward
  ];

  pyproject = true;
  pythonImportsCheck = [ "linuxpy" ];

  meta = {
    description = "Human friendly interface to Linux subsystems using Python";
    homepage = "https://github.com/tiagocoutinho/linuxpy";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ willow ];
    platforms = lib.platforms.linux;
  };
}
