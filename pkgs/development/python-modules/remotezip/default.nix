{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "remotezip";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "gtsystem";
    repo = "python-remotezip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TNEM7Dm4iH4Z/P/PAqjJppbn1CKmyi9Xpq/sU9O8uxg=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  pyproject = true;
  pythonImportsCheck = [ "remotezip" ];

  meta = {
    description = "Python module to access single members of a zip archive without downloading the full content";
    homepage = "https://github.com/gtsystem/python-remotezip";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "remotezip";
  };
})
