{
  lib,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  pytestCheckHook,
  scikit-image,
  scikit-learn,
  scipy,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "lime";
  version = "0.2.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-dpYOTwVf61Pom1AiODuvyHtj8lusYmWYSwozPRpX94E=";
  };

  postPatch = ''
    substituteInPlace lime/tests/test_scikit_image.py \
      --replace-fail "random_seed" "rng"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
    scipy
    tqdm
    scikit-learn
    scikit-image
  ];

  disabledTestPaths = [
    # touches network
    "lime/tests/test_lime_text.py"
    # slightly flaky
    "lime/tests/test_lime_tabular.py::TestLimeTabular::test_lime_explainer_entropy_discretizer"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lime.exceptions"
    "lime.explanation"
    "lime.lime_base"
    "lime.lime_image"
    "lime.lime_text"
  ];

  meta = {
    description = "Local Interpretable Model-Agnostic Explanations for machine learning classifiers";
    homepage = "https://github.com/marcotcr/lime";
    changelog = "https://github.com/marcotcr/lime/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ khaser ];
  };
})
