{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  # Python deps
  six,
}:

buildPythonPackage rec {
  pname = "mando";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "rubik";
    repo = "mando";
    rev = "v${version}";
    hash = "sha256-FuQZ53ojrQO++0TN0C3hk0LXH+mcfRqtGq8VvfYDufg=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ six ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "mando" ];

  meta = {
    description = "Create Python CLI apps with little to no effort at all";
    homepage = "https://mando.readthedocs.org";
    changelog = "https://github.com/rubik/mando/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ t4ccer ];
  };
}
