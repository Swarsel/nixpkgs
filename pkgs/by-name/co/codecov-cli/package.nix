{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "codecov-cli";
  version = "11.2.6";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "prevent-cli";
    tag = "v${version}";
    hash = "sha256-8KBemqwMqiio4pnftsBgnFj69Bgb5jQr5YlMegujPZY=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    ijson
    pyyaml
    responses
    sentry-sdk
    test-results-parser
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "click"
    "responses"
  ];

  sourceRoot = "${src.name}/${pname}";

  meta = {
    description = "Codecov Command Line Interface";
    homepage = "https://github.com/codecov/codecov-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
