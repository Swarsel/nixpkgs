{
  lib,
  fetchFromGitHub,
  # for passthru.tests
  aiobotocore,
  buildPythonPackage,
  flask,
  moto,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "flask-cors";
  version = "6.0.5";

  src = fetchFromGitHub {
    owner = "corydolphin";
    repo = "flask-cors";
    tag = finalAttrs.version;
    hash = "sha256-fngKJm7/7BMcWPPFncTCWw2sL1UJ0t4ICpXr95yNpbg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    flask
    werkzeug
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_cors" ];

  passthru.tests = {
    inherit aiobotocore moto;
  };

  meta = {
    description = "Flask extension adding a decorator for CORS support";
    homepage = "https://github.com/corydolphin/flask-cors";
    changelog = "https://github.com/corydolphin/flask-cors/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
