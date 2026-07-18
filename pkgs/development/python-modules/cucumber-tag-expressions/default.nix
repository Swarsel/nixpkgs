{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-html,
  pytestCheckHook,
  pyyaml,
  uv-build,
}:

buildPythonPackage rec {
  pname = "cucumber-tag-expressions";
  version = "9.1.0";

  src = fetchFromGitHub {
    owner = "cucumber";
    repo = "tag-expressions";
    tag = "v${version}";
    hash = "sha256-jkuez7C3YDGmv484Lmc5PszVbnVXkcC12RryvTJkxxg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.10.0,<0.11.0" uv_build
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-html
    pyyaml
  ];

  build-system = [
    uv-build
  ];

  pyproject = true;
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Provides tag-expression parser for cucumber/behave";
    homepage = "https://github.com/cucumber/tag-expressions";
    changelog = "https://github.com/cucumber/tag-expressions/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxxk ];
  };
}
