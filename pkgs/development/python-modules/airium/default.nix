{
  lib,
  fetchFromGitLab,
  beautifulsoup4,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "airium";
  version = "0.2.7";

  src = fetchFromGitLab {
    owner = "kamichal";
    repo = "airium";
    tag = "v${version}";
    hash = "sha256-sXyqGYBjyQ3Ig1idw+omrjj+ElknN9oemzob7NxFppo=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    # Tests require internet access, broken in sandbox
    "test_get_bad_content_type"
    "test_translate_remote_file"
  ];

  pyproject = true;

  meta = {
    description = "Bidirectional HTML-python translator";
    homepage = "https://gitlab.com/kamichal/airium";
    changelog = "https://gitlab.com/kamichal/airium/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hulr ];
    mainProgram = "airium";
  };
}
