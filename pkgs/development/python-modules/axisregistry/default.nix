{
  lib,
  buildPythonPackage,
  fetchPypi,
  fonttools,
  protobuf,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "axisregistry";
  version = "0.4.16";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eohwtlFSTuttPv0PsOy1uezGT1NNlwm8ZunVJd1a9zo=";
  };

  env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    fonttools
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "axisregistry" ];
  # Relax the dependency on protobuf 3. Other packages in the Google Fonts
  # ecosystem have begun upgrading from protobuf 3 to protobuf 4,
  # so we need to use protobuf 4 here as well to avoid a conflict
  # in the closure of fontbakery. It seems to be compatible enough.
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Google Fonts registry of OpenType variation axis tags";
    homepage = "https://github.com/googlefonts/axisregistry";
    changelog = "https://github.com/googlefonts/axisregistry/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
