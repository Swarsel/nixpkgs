{
  lib,
  fetchFromGitHub,
  autoconf,
  automake,
  buildPythonPackage,
  cmake,
  gcc,
  libtool,
  parameterized,
  perl,
  pytestCheckHook,
  setuptools,
  simplejson,
  snapshot-restore-py,
}:
buildPythonPackage rec {
  pname = "awslambdaric";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-lambda-python-runtime-interface-client";
    tag = version;
    sha256 = "sha256-wlQTYFbC/5gmal4xx9XHAxpdzEhGaD9N28BrhDUKV5A=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    libtool
    perl
    setuptools
  ];

  buildInputs = [ gcc ];

  propagatedBuildInputs = [
    simplejson
    snapshot-restore-py
  ];

  nativeCheckInputs = [
    parameterized
    pytestCheckHook
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "awslambdaric"
    "runtime_client"
  ];

  meta = {
    description = "AWS Lambda Runtime Interface Client for Python";
    homepage = "https://github.com/aws/aws-lambda-python-runtime-interface-client";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ austinbutler ];
    platforms = lib.platforms.linux;
  };
}
