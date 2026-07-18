{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  jinja2,
  lark,
  pysmi,
  pysnmp,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysmi";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "lextudio";
    repo = "pysmi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ft8R73eUgb+pnr35ZVc2Br3BGHhUDHEcQ9k/K6tjYBk=";
  };

  # Tests require pysnmp, which in turn requires pysmi => infinite recursion
  doCheck = false;

  nativeCheckInputs = [
    pysnmp
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    jinja2
    lark
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysmi" ];
  passthru.tests.pytest = pysmi.overridePythonAttrs { doCheck = true; };

  meta = {
    description = "SNMP MIB parser";
    homepage = "https://github.com/lextudio/pysmi";
    changelog = "https://github.com/lextudio/pysmi/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
})
