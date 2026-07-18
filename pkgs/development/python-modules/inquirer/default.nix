{
  lib,
  fetchFromGitHub,
  # propagated
  blessed,
  buildPythonPackage,
  editor,
  pexpect,
  # native
  poetry-core,
  # tests
  pytest-mock,
  pytestCheckHook,
  readchar,
}:

buildPythonPackage rec {
  pname = "inquirer";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "magmax";
    repo = "python-inquirer";
    tag = "v${version}";
    hash = "sha256-xVHmdJGN5yOxbEkZIiOLqeUwcfdj+o7jTTWBD75szII=";
  };

  nativeCheckInputs = [
    pexpect
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    blessed
    editor
    readchar
  ];

  pyproject = true;
  pythonImportsCheck = [ "inquirer" ];

  meta = {
    description = "Collection of common interactive command line user interfaces, based on Inquirer.js";
    homepage = "https://github.com/magmax/python-inquirer";
    changelog = "https://github.com/magmax/python-inquirer/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mmahut ];
  };
}
