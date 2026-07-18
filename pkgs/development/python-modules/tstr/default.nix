{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "tstr";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "ilotoki0804";
    repo = "tstr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vQ+PNbcrBRSskQDRwD++135SEIzbYKHDcy87Qj2oMNg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "tstr" ];

  meta = {
    description = "Backports of various template string utilities";
    homepage = "https://github.com/ilotoki0804/tstr";
    license = [ lib.licenses.asl20 ];
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
