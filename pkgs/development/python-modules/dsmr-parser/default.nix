{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dlms-cosem,
  pytestCheckHook,
  pythonAtLeast,
  serialx,
  setuptools,
  tailer,
}:

buildPythonPackage (finalAttrs: {
  pname = "dsmr-parser";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "ndokter";
    repo = "dsmr_parser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2q2e1/xt8a24QmACZUc9zWOnAiFhEYMg+44kOlx1JAk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    dlms-cosem
    serialx
    tailer
  ];

  pyproject = true;
  pythonImportsCheck = [ "dsmr_parser" ];
  pythonRelaxDeps = [ "dlms_cosem" ];

  meta = {
    description = "Python module to parse Dutch Smart Meter Requirements (DSMR)";
    homepage = "https://github.com/ndokter/dsmr_parser";
    changelog = "https://github.com/ndokter/dsmr_parser/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "dsmr_console";
  };
})
