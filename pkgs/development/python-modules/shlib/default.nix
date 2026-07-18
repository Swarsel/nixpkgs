{
  lib,
  fetchFromGitHub,
  braceexpand,
  buildPythonPackage,
  flit-core,
  inform,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "shlib";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "KenKundert";
    repo = "shlib";
    tag = "v${version}";
    hash = "sha256-ymX5Vz4QYrKX9GTsQMWtdLM4z0KtaSfZp0iTkCb/8aI=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = [
    braceexpand
    inform
  ];

  pyproject = true;
  pythonImportsCheck = [ "shlib" ];

  meta = {
    description = "Shell library";
    homepage = "https://github.com/KenKundert/shlib";
    changelog = "https://github.com/KenKundert/shlib/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
