{
  lib,
  fetchFromGitHub,
  brotli,
  brotlicffi,
  buildPythonPackage,
  hatchling,
  httpx,
  isPyPy,
  pytestCheckHook,
  pythonOlder,
  starlette,
  trio,
  zstandard,
}:

buildPythonPackage rec {
  pname = "starlette-compress";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "Zaczero";
    repo = "starlette-compress";
    tag = version;
    hash = "sha256-JRg0WeMVTYnSh2an+/duSXzAigbjbCZ9NUsSNpXlFg8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  checkInputs = [
    httpx
    trio
  ];

  build-system = [ hatchling ];

  dependencies = [
    (if isPyPy then brotlicffi else brotli)
    starlette
  ]
  ++ lib.optionals (pythonOlder "3.14") [
    zstandard
  ];

  pyproject = true;
  pythonImportsCheck = [ "starlette_compress" ];

  meta = {
    description = "Compression middleware for Starlette - supporting ZStd, Brotli, and GZip";
    homepage = "https://pypi.org/p/starlette-compress";
    license = lib.licenses.bsd0;

    maintainers = with lib.maintainers; [
      wrvsrx
      Zaczero
    ];
  };
}
