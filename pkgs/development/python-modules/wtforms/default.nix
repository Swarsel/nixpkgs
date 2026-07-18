{
  lib,
  fetchFromGitHub,
  # build-system
  babel,
  buildPythonPackage,
  # optional-dependencies
  email-validator,
  hatchling,
  # dependencies
  markupsafe,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wtforms";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "wtforms";
    repo = "wtforms";
    tag = version;
    hash = "sha256-jwjP/wkk8MdNJbPE8MlkrH4DyR304Ju41nN4lMo3jFs=";
  };

  nativeBuildInputs = [
    babel
    hatchling
    setuptools
  ];

  propagatedBuildInputs = [ markupsafe ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  optional-dependencies = {
    email = [ email-validator ];
  };

  pyproject = true;
  pythonImportsCheck = [ "wtforms" ];

  meta = {
    description = "Flexible forms validation and rendering library for Python";
    homepage = "https://github.com/wtforms/wtforms";
    changelog = "https://github.com/wtforms/wtforms/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
  };
}
