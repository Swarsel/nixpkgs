{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  sphinx,
}:
buildPythonPackage rec {
  pname = "sphinx-issues";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "sphinx-issues";
    tag = version;
    hash = "sha256-/nc5gtZbE1ziMPWIkZTkevMfVkNtJYL/b5QLDeMhzUs=";
  };

  postPatch = ''
    substituteInPlace tests/test_sphinx_issues.py \
      --replace-fail 'Path(sys.executable).parent.joinpath("sphinx-build")' '"${lib.getExe' sphinx "sphinx-build"}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_issues" ];

  meta = {
    description = "Sphinx extension for linking to your project's issue tracker";
    homepage = "https://github.com/sloria/sphinx-issues";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
