{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hyrule";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "hylang";
    repo = "hyrule";
    tag = version;
    hash = "sha256-nyB2vsXR1yiSzp1r/UCCQwM5FfIa4P8obTcWSu7JFoA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  # Some tests depends on hy on PATH
  preCheck = "PATH=${hy}/bin:$PATH";
  build-system = [ setuptools ];
  dependencies = [ hy ];
  pyproject = true;
  pythonImportsCheck = [ "hyrule" ];

  meta = {
    description = "Utility library for the Hy programming language";
    homepage = "https://github.com/hylang/hyrule";
    changelog = "https://github.com/hylang/hyrule/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
