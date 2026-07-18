{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "lcov-cobertura";
  version = "2.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-76jiZPK93rt/UCTkrOErYz2dWQSLxkdCfR4blojItY8=";
    pname = "lcov_cobertura";
  };

  # https://github.com/eriwen/lcov-to-cobertura-xml/issues/63
  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail 'License :: OSI Approved :: Apache Software License' ""
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ distutils ];
  pyproject = true;
  pythonImportsCheck = [ "lcov_cobertura" ];

  meta = {
    description = "Converts code coverage from lcov format to Cobertura's XML format";
    homepage = "https://eriwen.github.io/lcov-to-cobertura-xml/";
    license = lib.licenses.asl20;
    mainProgram = "lcov_cobertura";
  };
}
