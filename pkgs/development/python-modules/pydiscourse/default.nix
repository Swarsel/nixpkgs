{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-mock,
  pytestCheckHook,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "pydiscourse";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "pydiscourse";
    repo = "pydiscourse";
    tag = "v${version}";
    hash = "sha256-KqJ6ag4owG7US5Q4Ygjq263ds1o/JhEJ3bNa8YecYtE=";
  };

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
    requests-mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pydiscourse" ];

  meta = {
    description = "Python library for working with Discourse";
    homepage = "https://github.com/pydiscourse/pydiscourse";
    changelog = "https://github.com/pydiscourse/pydiscourse/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Dettorer ];
    mainProgram = "pydiscoursecli";
  };
}
