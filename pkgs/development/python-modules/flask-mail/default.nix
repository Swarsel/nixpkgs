{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  flask,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "flask-mail";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-mail";
    tag = finalAttrs.version;
    hash = "sha256-G2Z8dj1/IuLsZoNJVrL6LYu0XjTEHtWB9Z058aqG9Ic=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = [
    blinker
    flask
  ];

  disabledTests = [
    # Broken by fix for CVE-2023-27043.
    # Reported upstream in https://github.com/pallets-eco/flask-mail/issues/233
    "test_unicode_sender_tuple"
    "test_unicode_sender"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_mail" ];

  meta = {
    description = "Flask extension providing simple email sending capabilities";
    homepage = "https://github.com/pallets-eco/flask-mail";
    changelog = "https://github.com/pallets-eco/flask-mail/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.bsd3;
  };
})
