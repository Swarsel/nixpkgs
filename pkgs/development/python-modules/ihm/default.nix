{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  msgpack,
  pytestCheckHook,
  setuptools,
  swig,
}:

buildPythonPackage (finalAttrs: {
  pname = "ihm";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "ihmwg";
    repo = "python-ihm";
    tag = finalAttrs.version;
    hash = "sha256-X7hWuSltv6XZ7ugRcJQRYR0MNoqqVbl+i7tF9JafwFg=";
  };

  nativeBuildInputs = [ swig ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ msgpack ];

  disabledTests = [
    # requires network access
    "test_validator_example"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ihm" ];

  meta = {
    description = "Python package for handling IHM mmCIF and BinaryCIF files";
    homepage = "https://github.com/ihmwg/python-ihm";
    changelog = "https://github.com/ihmwg/python-ihm/blob/${finalAttrs.src.tag}/ChangeLog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})
