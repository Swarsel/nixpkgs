{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pybind11,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "chroma-hnswlib";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "chroma-core";
    repo = "hnswlib";
    tag = version;
    hash = "sha256-Fs/BuocZblMSlmP6yp+aykbs0n1AdvL3AVAQI1AnZ9o=";
  };

  nativeBuildInputs = [
    numpy
    pybind11
    setuptools
    wheel
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "hnswlib" ];

  meta = {
    description = "Header-only C++/python library for fast approximate nearest neighbors";
    homepage = "https://github.com/chroma-core/hnswlib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
