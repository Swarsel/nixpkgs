{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  setuptools,
  swig,
}:

buildPythonPackage rec {
  pname = "pykcs11";
  version = "1.5.18";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ev2HizaYIdgMG+ihQMheig+xNY/Kq6ZspmhpITaS8ic=";
  };

  outputs = [
    "out"
    "testout"
  ];

  nativeBuildInputs = [ swig ];
  doCheck = false;

  postInstall = ''
    mkdir $testout
    cp -R test $testout/test
  '';

  build-system = [ setuptools ];
  pypaBuildFlags = [ "--skip-dependency-check" ];
  pyproject = true;
  pythonImportsCheck = [ "PyKCS11" ];

  # tests complain about circular import, do testing with passthru.tests instead
  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "PKCS#11 wrapper for Python";
    homepage = "https://github.com/LudovicRousseau/PyKCS11";
    changelog = "https://github.com/LudovicRousseau/PyKCS11/releases/tag/${version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hulr ];
  };
}
