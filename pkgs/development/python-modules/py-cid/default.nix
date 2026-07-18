{
  lib,
  fetchFromGitHub,
  base58,
  buildPythonPackage,
  hypothesis,
  morphys,
  py-multibase,
  py-multicodec,
  py-multihash,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py-cid";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "ipld";
    repo = "py-cid";
    tag = "v${version}";
    hash = "sha256-ufApwZW+MJHPiiEG/E221KTlOqwNN8icb9fcn/cX1AQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    hypothesis
  ];

  build-system = [ setuptools ];

  dependencies = [
    base58
    py-multibase
    py-multicodec
    morphys
    py-multihash
  ];

  pyproject = true;
  pythonImportsCheck = [ "cid" ];
  pythonRelaxDeps = [ "base58" ];

  meta = {
    description = "Self-describing content-addressed identifiers for distributed systems implementation in Python";
    homepage = "https://github.com/ipld/py-cid";
    changelog = "https://github.com/ipld/py-cid/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
