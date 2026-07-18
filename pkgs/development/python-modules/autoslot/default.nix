{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "autoslot";
  version = "2025.11.1";

  src = fetchFromGitHub {
    owner = "cjrh";
    repo = "autoslot";
    tag = "v${version}";
    hash = "sha256-mPGfBUSKkskiiokqo/TJWdDzuvcg/LDULx+Gx8LexV8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "autoslot" ];

  meta = {
    description = "Automatic __slots__ for your Python classes";
    homepage = "https://github.com/cjrh/autoslot";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
