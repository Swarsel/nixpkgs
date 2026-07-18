{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagates
  cryptography,
  # build-system
  cython,
  poetry-core,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

let
  pname = "chacha20poly1305-reuseable";
  version = "0.13.2";
in

buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "chacha20poly1305-reuseable";
    tag = "v${version}";
    hash = "sha256-i6bhqfYo+gFTf3dqOBSQqGN4WPqbUR05StdwZvrVckI=";
  };

  nativeBuildInputs = [
    cython
    poetry-core
    setuptools
  ];

  propagatedBuildInputs = [ cryptography ];

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "chacha20poly1305_reuseable" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "ChaCha20Poly1305 that is reuseable for asyncio";
    homepage = "https://github.com/bdraco/chacha20poly1305-reuseable";
    changelog = "https://github.com/bdraco/chacha20poly1305-reuseable/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
