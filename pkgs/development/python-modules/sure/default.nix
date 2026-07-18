{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  mock,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "sure";
  version = "2.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yPxvq8Dn9phO6ruUJUDkVkblvvC7mf5Z4C2mNOTUuco=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "rednose = 1" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    mock
    six
  ];

  disabledTestPaths = [
    "tests/test_old_api.py" # require nose
  ];

  disabledTests = lib.optionals isPyPy [
    # test extension of 'dict' object is broken
    "test_should_compare_dict_with_non_orderable_key_types"
    "test_should_compare_dict_with_enum_keys"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sure" ];

  meta = {
    description = "Utility belt for automated testing";
    homepage = "https://sure.readthedocs.io/";
    changelog = "https://github.com/gabrielfalcao/sure/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "sure";
  };
})
