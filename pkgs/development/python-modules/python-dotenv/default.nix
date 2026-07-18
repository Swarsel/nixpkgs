{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  ipython,
  pytestCheckHook,
  setuptools,
  sh,
}:

buildPythonPackage rec {
  pname = "python-dotenv";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "theskumar";
    repo = "python-dotenv";
    tag = "v${version}";
    hash = "sha256-MoBt3QsY5u3r852MtVWZS9tFXpyK8aRZlLG3rpzIVrY=";
  };

  nativeCheckInputs = [
    ipython
    pytestCheckHook
    sh
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  build-system = [ setuptools ];
  optional-dependencies.cli = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "dotenv" ];

  meta = {
    description = "Add .env support to your django/flask apps in development and deployments";
    homepage = "https://github.com/theskumar/python-dotenv";
    changelog = "https://github.com/theskumar/python-dotenv/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ erikarvstedt ];
    mainProgram = "dotenv";
  };
}
