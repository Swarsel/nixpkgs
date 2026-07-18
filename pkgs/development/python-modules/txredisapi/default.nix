{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nixosTests,
  setuptools,
  six,
  twisted,
}:

buildPythonPackage rec {
  pname = "txredisapi";
  version = "1.4.12";

  src = fetchFromGitHub {
    owner = "IlyaSkriblovsky";
    repo = "txredisapi";
    tag = version;
    hash = "sha256-jvxqHYDRTnG1X+VkC1syTM/W+CRiL9w4Ehf7pe147Uo=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    six
    twisted
  ]
  ++ twisted.optional-dependencies.tls;

  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "txredisapi" ];
  passthru.tests.unit-tests = nixosTests.txredisapi;

  meta = {
    description = "Non-blocking redis client for python";
    homepage = "https://github.com/IlyaSkriblovsky/txredisapi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
