{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pygmars";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "nexB";
    repo = "pygmars";
    tag = "v${version}";
    hash = "sha256-AbBhWR9ycOFrxS7Vz0bSsSyS3FEEm2bXJAvMhIba6XQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pygmars" ];

  meta = {
    description = "Python lexing and parsing library";
    homepage = "https://github.com/nexB/pygmars";
    changelog = "https://github.com/aboutcode-org/pygmars/blob/${src.tag}/CHANGELOG.rst";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
