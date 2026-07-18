{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  parsley,
  python,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
  twisted,
}:

buildPythonPackage rec {
  pname = "txi2p-tahoe";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "txi2p";
    tag = version;
    hash = "sha256-u/IOhxK9jWC/tTKKLsc4PexbCuki+yEtMNw7LuQKmuk=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    parsley
    twisted
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m twisted.trial txi2p
    runHook postCheck
  '';

  # 194/263 tests fail on python 3.14
  # https://github.com/tahoe-lafs/txi2p/issues/10
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  pythonImportsCheck = [ "txi2p" ];

  meta = {
    description = "I2P bindings for Twisted";
    homepage = "https://github.com/tahoe-lafs/txi2p";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
