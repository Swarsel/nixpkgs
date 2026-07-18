{
  lib,
  buildPythonPackage,
  fetchPypi,
  protobuf,
  pytestCheckHook,
  regex,
  setuptools,
  setuptools-scm,
  uharfbuzz,
  youseedee,
}:

buildPythonPackage rec {
  pname = "gflanguages";
  version = "0.7.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JR+lmwGhPR/RoskpouNzGOE9kRgvSGgzx5Xa196k0eA=";
  };

  env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";

  nativeCheckInputs = [
    pytestCheckHook
    regex
    uharfbuzz
    youseedee
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    protobuf
    regex
  ];

  disabledTests = [
    # AssertionError
    "test_exemplars_are_in_script"
    "test_sample_texts_are_in_script"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gflanguages" ];
  # Relax the dependency on protobuf 3. Other packages in the Google Fonts
  # ecosystem have begun upgrading from protobuf 3 to protobuf 4,
  # so we need to use protobuf 4 here as well to avoid a conflict
  # in the closure of fontbakery. It seems to be compatible enough.
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Python library for Google Fonts language metadata";
    homepage = "https://github.com/googlefonts/lang";
    changelog = "https://github.com/googlefonts/lang/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
