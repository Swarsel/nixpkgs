{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "updog";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "sc0tfree";
    repo = "updog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EFAqxlKrQ9HBMHBdmstY+RZPqK0kWY5Ws6WMFHlMyM0=";
  };

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    colorama
    flask
    flask-cors
    flask-httpauth
    pyopenssl
    werkzeug
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "pyopenssl"
    "flask-cors"
  ];

  # no python tests
  meta = {
    description = "Replacement for Python's SimpleHTTPServer";
    homepage = "https://github.com/sc0tfree/updog";
    changelog = "https://github.com/sc0tfree/updog/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    mainProgram = "updog";
  };
})
