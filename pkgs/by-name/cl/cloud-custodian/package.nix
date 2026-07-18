{
  lib,
  fetchFromGitHub,
  python3,
  versionCheckHook,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cloud-custodian";
  version = "0.9.51.0";

  src = fetchFromGitHub {
    owner = "cloud-custodian";
    repo = "cloud-custodian";
    tag = finalAttrs.version;
    hash = "sha256-vL+/Sof61EkVjudwyFnYnkFi2Hggx9NFrvY8nRTaU+0=";
  };

  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    argcomplete
    boto3
    botocore
    certifi
    docutils
    importlib-metadata
    jsonpatch
    cryptography
    jsonschema
    python-dateutil
    pyyaml
    tabulate
    urllib3
  ];

  preVersionCheck = ''
    version=${lib.versions.pad 3 finalAttrs.version}
  '';

  pyproject = true;

  pythonImportsCheck = [
    "c7n"
  ];

  pythonRelaxDeps = [
    "docutils"
    "importlib-metadata"
    "referencing"
    "tabulate"
    "urllib3"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Rules engine for cloud security, cost optimization, and governance";
    homepage = "https://cloudcustodian.io";
    changelog = "https://github.com/cloud-custodian/cloud-custodian/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jlesquembre ];
    mainProgram = "custodian";
  };
})
