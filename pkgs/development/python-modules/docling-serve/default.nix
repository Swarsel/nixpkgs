{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # python dependencies
  docling,
  docling-jobkit,
  docling-mcp,
  fastapi,
  gradio,
  hatchling,
  httpx,
  nodejs,
  onnxruntime,
  pydantic-settings,
  python-multipart,
  rapidocr,
  scalar-fastapi,
  setuptools-scm,
  tesserocr,
  torch,
  torchvision,
  typer,
  uvicorn,
  websockets,
  which,
  withCPU ? false,
  withRapidocr ? false,
  withTesserocr ? false,
  withUI ? false,
}:

buildPythonPackage rec {
  pname = "docling-serve";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-serve";
    tag = "v${version}";
    hash = "sha256-g0ATehTRtrqgTjvMTs+yvFdFwXTZ8AWsO+Hljwlcbto=";
  };

  # Require network
  doCheck = false;

  build-system = [
    hatchling
    setuptools-scm
  ];

  dependencies = [
    docling
    docling-jobkit
    docling-mcp
    fastapi
    httpx
    pydantic-settings
    python-multipart
    scalar-fastapi
    typer
    uvicorn
    websockets
  ]
  ++ lib.optionals withUI optional-dependencies.ui
  ++ lib.optionals withTesserocr optional-dependencies.tesserocr
  ++ lib.optionals withRapidocr optional-dependencies.rapidocr
  ++ lib.optionals withCPU optional-dependencies.cpu;

  optional-dependencies = {
    cpu = [
      torch
      torchvision
    ];

    rapidocr = [
      rapidocr
      onnxruntime
    ];

    tesserocr = [
      tesserocr
    ];

    ui = [
      gradio
      nodejs
      which
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "docling_serve"
  ];

  pythonRelaxDeps = [
    "websockets"
  ];

  pythonRemoveDeps = [
    "mlx-vlm" # not yet available on nixpkgs
  ];

  meta = {
    description = "Running Docling as an API service";
    homepage = "https://github.com/docling-project/docling-serve";
    changelog = "https://github.com/docling-project/docling-serve/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "docling-serve";
  };
}
