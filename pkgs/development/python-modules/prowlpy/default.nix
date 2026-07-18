{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cacert,
  loguru,
  pyreqwest,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  respx,
  setuptools,
  typer,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "prowlpy";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "OMEGARAZER";
    repo = "prowlpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-92r1E/dsXLRzaLXQdahXAPCmSG4T1Ihh/eDFDG3GlmY=";
  };

  nativeCheckInputs = [
    cacert
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    respx
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    pyreqwest
    xmltodict
  ];

  optional-dependencies = {
    cli = [
      loguru
      typer
    ];
  };

  pyproject = true;
  # tests fail without this
  pytestFlags = [ "-v" ];
  pythonImportsCheck = [ "prowlpy" ];

  meta = {
    description = "Send push notifications to iPhones using the Prowl API";
    homepage = "https://github.com/OMEGARAZER/prowlpy";
    changelog = "https://github.com/OMEGARAZER/prowlpy/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "prowlpy";
  };
})
