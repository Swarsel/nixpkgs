{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  googleapis-common-protos,
  protobuf,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "proto-plus";
  version = "1.27.1";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "proto-plus-python";
    tag = "v${version}";
    hash = "sha256-B+CkOLzbpu3XXnH7MND5GCljG/bUyPPU57zXIIXoRiU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytz
    googleapis-common-protos
  ];

  build-system = [ setuptools ];
  dependencies = [ protobuf ];
  pyproject = true;

  pytestFlags = [
    # pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    "-Wignore::DeprecationWarning"
    # float_precision option is deprecated for json_format error with latest protobuf
    "-Wignore:float_precision:UserWarning"
  ];

  pythonImportsCheck = [ "proto" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Beautiful, idiomatic protocol buffers in Python";
    homepage = "https://github.com/googleapis/proto-plus-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ruuda ];
  };
}
