{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytest8_3CheckHook,
  setuptools-scm,
  # build-system
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "makefun";
  version = "1.16.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4UYBgxVwv/H21+aIKLzTDS9YVvJLrV3gzLIpIc7ryUc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools>=39.2,<72"' '"setuptools"'
  '';

  nativeCheckInputs = [
    pytest8_3CheckHook
  ];

  build-system = [
    setuptools_80
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "makefun" ];

  meta = {
    description = "Small library to dynamically create python functions";
    homepage = "https://github.com/smarie/python-makefun";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
