{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "texsoup";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "alvinwan";
    repo = "TexSoup";
    tag = finalAttrs.version;
    hash = "sha256-CKUDDq+97kktQnsdwOkwLILdsE7CkQMxId30fbWX90c=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "TexSoup" ];

  meta = {
    description = "Fault-tolerant Python3 package for searching, navigating, and modifying LaTeX documents";
    homepage = "https://github.com/alvinwan/TexSoup";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
