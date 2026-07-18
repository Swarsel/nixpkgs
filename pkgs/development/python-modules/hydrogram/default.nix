{
  lib,
  fetchFromGitHub,
  aiosqlite,
  buildPythonPackage,
  fetchpatch2,
  hatchling,
  pyaes,
  pysocks,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hydrogram";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "hydrogram";
    repo = "hydrogram";
    tag = "v${version}";
    hash = "sha256-QpweUDCypTxOOWL08gCUuMgbuE4130iNyxRpUNuSBac=";
  };

  patches = [
    (fetchpatch2 {
      excludes = [ ".github/workflows/code-style.yml" ];
      hash = "sha256-MPv13cxnNPDD+p9EPjDPFqydGy57oXzLeRxL3lG8JKU=";
      name = "fix-async-in-test.patch";
      url = "https://github.com/hydrogram/hydrogram/commit/7431319a1d990aa838012bd566a9746da7df2a6e.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ hatchling ];

  dependencies = [
    pyaes
    pysocks
    aiosqlite
  ];

  pyproject = true;

  pythonImportsCheck = [
    "hydrogram"
    "hydrogram.errors"
    "hydrogram.types"
  ];

  meta = {
    description = "Asynchronous Telegram MTProto API framework for fluid user and bot interactions";
    homepage = "https://github.com/hydrogram/hydrogram";
    changelog = "https://github.com/hydrogram/hydrogram/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ tholo ];
  };
}
