{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "bytecode";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "MatthieuDartiailh";
    repo = "bytecode";
    tag = version;
    hash = "sha256-hjPjF7xC7v2dZ6espAcru2sb7/6AEb3D1MYO0ekzJds=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "bytecode" ];

  meta = {
    description = "Python module to generate and modify bytecode";
    homepage = "https://github.com/vstinner/bytecode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ raboof ];
  };
}
