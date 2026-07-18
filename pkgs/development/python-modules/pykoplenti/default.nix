{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  click,
  hatchling,
  prompt-toolkit,
  pycryptodome,
  pydantic,
}:

buildPythonPackage (finalAttrs: {
  pname = "pykoplenti";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "stegm";
    repo = "pykoplenti";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Mwh6QOdsvf32U09ebleEKL7vt3xz8tjiftVVxKL/lO4=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    pycryptodome
    pydantic
  ];

  optional-dependencies = {
    CLI = [
      click
      prompt-toolkit
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pykoplenti" ];
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Python REST client API for Kostal Plenticore Inverters";
    homepage = "https://github.com/stegm/pykoplenti/";
    changelog = "https://github.com/stegm/pykoplenti/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pykoplenti";
  };
})
