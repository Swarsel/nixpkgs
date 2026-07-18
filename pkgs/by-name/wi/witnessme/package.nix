{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "witnessme";
  version = "0-unstable-2023-12-06";

  src = fetchFromGitHub {
    owner = "byt3bl33d3r";
    repo = "WitnessMe";
    # https://github.com/byt3bl33d3r/WitnessMe/issues/47
    rev = "16d4a377eba653315e827b0af686b948681be301";
    hash = "sha256-CMbeGLwXqpeB31x1j8qU8Bbi3EHEmLokDtqbQER1gEA=";
  };

  patches = [
    # Switch to poetry-core, https://github.com/byt3bl33d3r/WitnessMe/pull/48
    (fetchpatch {
      hash = "sha256-ZcIt/ueLgVlZePgxYljRFtvF5t2zlB80HsNyjheCnxI=";
      name = "switch-poetry-core.patch";
      url = "https://github.com/byt3bl33d3r/WitnessMe/commit/147ce9fc7c9ac84712aa1ba2f7073bc2f29c8afe.patch";
    })
  ];

  nativeCheckInputs = with python3.pkgs; [
    httpx
    pytest-asyncio
    pytestCheckHook
    setuptools
  ];

  build-system = with python3.pkgs; [
    poetry-core
  ];

  dependencies = with python3.pkgs; [
    aiodns
    aiofiles
    aiosqlite
    fastapi
    imgcat
    jinja2
    lxml
    prompt-toolkit
    pydantic
    pyppeteer
    python-multipart
    pyyaml
    terminaltables
    uvicorn
    xmltodict
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_api.py"
    "tests/test_grab.py"
    "tests/test_scan.py"
    "tests/test_target_parsing.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "witnessme"
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "Web Inventory tool";
    homepage = "https://github.com/byt3bl33d3r/WitnessMe";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "witnessme";
  };
}
