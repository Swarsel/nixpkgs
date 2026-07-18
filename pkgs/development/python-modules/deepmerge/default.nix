{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "deepmerge";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-B8p6e4k131lsUS+oFhh3wEh6xh9pHAd2bn1x0rI73S8=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "deepmerge" ];

  meta = {
    description = "Toolset to deeply merge python dictionaries";
    homepage = "http://deepmerge.readthedocs.io/en/latest/";
    changelog = "https://github.com/toumorokoshi/deepmerge/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    downloadPage = "https://github.com/toumorokoshi/deepmerge";
  };
}
