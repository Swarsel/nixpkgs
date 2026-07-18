{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  uv-build,
}:

buildPythonPackage rec {
  pname = "cucumber-expressions";
  version = "19.0.1";

  src = fetchFromGitHub {
    owner = "cucumber";
    repo = "cucumber-expressions";
    tag = "v${version}";
    hash = "sha256-RosIA8LaXdpnqJYfowB4d1gWZTd8OfuetiBLNYX5dRc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.11.0,<0.12.0" uv_build
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ uv-build ];
  pyproject = true;
  pythonImportsCheck = [ "cucumber_expressions" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Human friendly alternative to Regular Expressions";
    homepage = "https://github.com/cucumber/cucumber-expressions/tree/main/python";
    changelog = "https://github.com/cucumber/cucumber-expressions/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
