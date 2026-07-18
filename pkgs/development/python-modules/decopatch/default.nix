{
  lib,
  buildPythonPackage,
  fetchPypi,
  makefun,
  setuptools-scm,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "decopatch";
  version = "1.4.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lX9JyT9BUBgsI/j7UdE7syE+DxenngnIzKcFdZi1VyA=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "pytest-runner" ""
  '';

  # Tests would introduce multiple circular dependencies
  # Affected: makefun, pytest-cases
  doCheck = false;

  build-system = [
    setuptools_80
    setuptools-scm
  ];

  dependencies = [ makefun ];
  pyproject = true;
  pythonImportsCheck = [ "decopatch" ];

  meta = {
    description = "Python helper for decorators";
    homepage = "https://github.com/smarie/python-decopatch";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
