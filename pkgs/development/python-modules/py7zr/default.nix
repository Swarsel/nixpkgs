{
  lib,
  fetchFromGitHub,
  brotli,
  buildPythonPackage,
  inflate64,
  multivolumefile,
  psutil,
  py-cpuinfo,
  pybcj,
  pycryptodomex,
  pyppmd,
  pytest-benchmark,
  pytest-httpserver,
  pytest-remotedata,
  pytest-timeout,
  pytestCheckHook,
  pyzstd,
  requests,
  setuptools,
  setuptools-scm,
  texttable,
}:

buildPythonPackage rec {
  pname = "py7zr";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "miurahr";
    repo = "py7zr";
    tag = "v${version}";
    hash = "sha256-/sorvv5/kwlY/DtxW33ytHhyrR06p6aNgGW9oH+lpUw=";
  };

  nativeCheckInputs = [
    py-cpuinfo
    pytest-benchmark
    pytest-httpserver
    pytest-remotedata
    pytest-timeout
    pytestCheckHook
    requests
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    brotli
    inflate64
    multivolumefile
    psutil
    pybcj
    pycryptodomex
    pyppmd
    pyzstd
    texttable
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];

  pythonImportsCheck = [
    "py7zr"
  ];

  pythonRelaxDeps = [
    "pyppmd"
    "pybcj"
    "inflate64"
  ];

  meta = {
    description = "7zip in Python 3 with ZStandard, PPMd, LZMA2, LZMA1, Delta, BCJ, BZip2";
    homepage = "https://github.com/miurahr/py7zr";

    changelog = "https://github.com/miurahr/py7zr/blob/v${version}/docs/Changelog.rst#v${
      builtins.replaceStrings [ "." ] [ "" ] version
    }";

    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      pitkling
      PopeRigby
    ];
  };
}
