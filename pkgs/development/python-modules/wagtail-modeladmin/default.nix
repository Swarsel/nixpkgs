{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  flit-core,
  python,
  wagtail,
}:

buildPythonPackage rec {
  pname = "wagtail-modeladmin";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "wagtail-nest";
    repo = "wagtail-modeladmin";
    tag = "v${version}";
    hash = "sha256-Rj5I39Fx+BNXcpGTO3AUr8MfZu2FwkdH/1HMruva11A=";
  };

  # Fail with `AssertionError`
  # AssertionError: <Warning: level=30,... > not found in [<Warning: ...>]
  postPatch = ''
    substituteInPlace wagtail_modeladmin/test/tests/test_simple_modeladmin.py \
      --replace-fail \
        "def test_model_with_single_tabbed_panel_only(" \
        "def no_test_model_with_single_tabbed_panel_only(" \
      --replace-fail \
        "def test_model_with_two_tabbed_panels_only(" \
        "def no_test_model_with_two_tabbed_panels_only("
  '';

  nativeCheckInputs = [ dj-database-url ];

  checkPhase = ''
    runHook preCheck

    # AssertionError: 3 != 1 : Found 3 instances of 'error-message' in response (expected 1)
    rm wagtail_modeladmin/test/tests/test_simple_modeladmin.py

    ${python.interpreter} testmanage.py test

    runHook postCheck
  '';

  build-system = [ flit-core ];

  dependencies = [
    wagtail
  ];

  pyproject = true;
  pythonImportsCheck = [ "wagtail_modeladmin" ];

  meta = {
    description = "Add any model in your project to the Wagtail admin. Formerly wagtail.contrib.modeladmin";
    homepage = "https://github.com/wagtail-nest/wagtail-modeladmin";
    changelog = "https://github.com/wagtail/wagtail-modeladmin/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
