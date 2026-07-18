{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  construct,
  packaging,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "snapcast";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "happyleavesaoc";
    repo = "python-snapcast";
    tag = version;
    hash = "sha256-AWGpKtkki5I7VkKSSOBKUss2ULzOKVuKP/8mrU3VmqI=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    construct
    packaging
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # AssertionError and TypeError
    "test_stream_setmeta"
    "est_stream_setproperty"
  ];

  pyproject = true;
  pythonImportsCheck = [ "snapcast" ];

  meta = {
    description = "Control Snapcast, a multi-room synchronous audio solution";
    homepage = "https://github.com/happyleavesaoc/python-snapcast/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
