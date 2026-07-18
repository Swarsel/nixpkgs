{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bottle";
  version = "0.13.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-eH54Mn4SsieTjeAiSDM9eIz+RZh+3Kc1+PiOA0csP0c=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd test
  '';

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    "test_delete_cookie"
    "test_error"
    "test_error_in_generator_callback"
    # timing sensitive
    "test_ims"
  ]
  ++ lib.optionals (pythonAtLeast "3.12") [
    # https://github.com/bottlepy/bottle/issues/1422
    # ModuleNotFoundError: No module named 'bottle.ext'
    "test_data_import"
    "test_direkt_import"
    "test_from_import"
  ];

  pyproject = true;

  meta = {
    description = "Fast and simple micro-framework for small web-applications";
    homepage = "https://bottlepy.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
    mainProgram = "bottle.py";
    downloadPage = "https://github.com/bottlepy/bottle";
  };
})
