{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "flask-paginate";
  version = "2024.4.12";

  src = fetchFromGitHub {
    owner = "lixxu";
    repo = "flask-paginate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YaAgl+iuoXB0eWVzhmNq2UTOpM/tHfDISIb9CyaXiuA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ flask ];
  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flask_paginate" ];

  meta = {
    description = "Pagination support for Flask";
    homepage = "https://github.com/lixxu/flask-paginate";
    changelog = "https://github.com/lixxu/flask-paginate/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
