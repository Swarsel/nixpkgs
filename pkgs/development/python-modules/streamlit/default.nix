{
  lib,
  stdenv,
  altair,
  anyio,
  blinker,
  buildPythonPackage,
  cachetools,
  click,
  fetchPypi,
  gitpython,
  httptools,
  itsdangerous,
  numpy,
  packaging,
  pandas,
  pillow,
  protobuf,
  pyarrow,
  pydeck,
  python-multipart,
  requests,
  rich,
  setuptools,
  starlette,
  tenacity,
  toml,
  tornado,
  typing-extensions,
  uvicorn,
  watchdog,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "streamlit";
  version = "1.58.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-eKIucIWwU6985UREK/S2cHceaMUJuhvaoFa6Bwj0nD0=";
  };

  # pypi package does not include the tests, but cannot be built with fetchFromGitHub
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    altair
    anyio
    blinker
    cachetools
    click
    gitpython
    httptools
    itsdangerous
    numpy
    packaging
    pandas
    pillow
    protobuf
    pyarrow
    pydeck
    python-multipart
    requests
    rich
    starlette
    tenacity
    toml
    tornado
    typing-extensions
    uvicorn
    websockets
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ watchdog ];

  pyproject = true;
  pythonImportsCheck = [ "streamlit" ];

  pythonRelaxDeps = [
    "packaging"
    "protobuf"
  ];

  meta = {
    description = "Fastest way to build custom ML tools";
    homepage = "https://streamlit.io/";
    changelog = "https://github.com/streamlit/streamlit/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      natsukium
      yrashk
    ];

    mainProgram = "streamlit";
  };
})
