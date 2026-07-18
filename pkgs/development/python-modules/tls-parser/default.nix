{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tls-parser";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "nabla-c0d3";
    repo = "tls_parser";
    tag = version;
    hash = "sha256-nNQ5XLsZMUXmsTnaqiUeaaHtiVc5r4woRxeYVhO3ICY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "tls_parser" ];

  meta = {
    description = "Small library to parse TLS records";
    homepage = "https://github.com/nabla-c0d3/tls_parser";
    changelog = "https://github.com/nabla-c0d3/tls_parser/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veehaitch ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
