{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "huepy";
  version = "1.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Wym+73lzEvt2BhiLxc2Y94q49+AVdkJ6kxLxybILdZ0=";
    pname = "huepy";
  };

  # no test
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "huepy" ];

  meta = {
    description = "Print awesomely in terminals";
    homepage = "https://pypi.org/project/huepy/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tochiaha ];
    platforms = lib.platforms.all;
  };
}
