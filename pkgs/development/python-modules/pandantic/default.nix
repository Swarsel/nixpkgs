{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  multiprocess,
  pandas,
  pandas-stubs,
  poetry-core,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pandantic";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "wesselhuising";
    repo = "pandantic";
    tag = version;
    hash = "sha256-lqd4aQiBMbATFMdftKQeTlqQ3MGrxm2shb7qil+84iA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    multiprocess
    pandas
    pandas-stubs
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "pandantic" ];

  meta = {
    description = "Module to enriche the Pydantic BaseModel class";
    homepage = "https://github.com/wesselhuising/pandantic";
    changelog = "https://github.com/wesselhuising/pandantic/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
