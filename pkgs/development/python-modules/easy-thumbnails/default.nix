{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pillow,
  pytest-django,
  pytestCheckHook,
  reportlab,
  setuptools,
  svglib,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "easy-thumbnails";
  version = "2.10.1";

  src = fetchFromGitHub {
    owner = "SmileyChris";
    repo = "easy-thumbnails";
    tag = version;
    hash = "sha256-GPZ99OaQRSogS8gJXz8rVUjUeNkEk019TYx0VWa0Q6I=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ]
  ++ lib.concatAttrValues optional-dependencies;

  checkInputs = [ testfixtures ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE="easy_thumbnails.tests.settings"
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    pillow
  ];

  disabledTests = [
    # AssertionError: 'ERROR' != 'INFO'
    "test_postprocessor"
  ];

  optional-dependencies.svg = [
    reportlab
    svglib
  ];

  pyproject = true;
  pythonImportsCheck = [ "easy_thumbnails" ];

  meta = {
    description = "Easy thumbnails for Django";
    homepage = "https://github.com/SmileyChris/easy-thumbnails";
    changelog = "https://github.com/SmileyChris/easy-thumbnails/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.onny ];
  };
}
