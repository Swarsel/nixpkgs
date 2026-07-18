{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "color-parser-py";
  version = "0.1.7";

  # PyPI has Cargo.lock
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-C3Q9vaOa/SE0PtQu5Gw/sk1JMRIlhgbA5VTW+2aC5dU=";
    pname = "color_parser_py";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # Support newer python versions
  env.PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true;
  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-nyl0Nmf0DNLH3j2XrTTO1u3erBCbRyp/xO0w/USjDHE=";
  };

  pyproject = true;
  pythonImportsCheck = [ "color_parser_py" ];

  meta = {
    description = "Python bindings for color parsing and conversion";
    homepage = "https://github.com/rusiaaman/color-parser-py";
    changelog = "https://github.com/rusiaaman/color-parser-py/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
  };
})
