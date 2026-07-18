{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  haversine,
  medallion,
  pytestCheckHook,
  pytz,
  rapidfuzz,
  requests,
  setuptools,
  simplejson,
  stix2-patterns,
  taxii2-client,
}:

buildPythonPackage (finalAttrs: {
  pname = "stix2";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "oasis-open";
    repo = "cti-python-stix2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qm6VFufD9A4rSBHaDkqeYqOLRvE97SY0++o4ND0l3I0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    haversine
    medallion
    rapidfuzz
    taxii2-client
  ];

  build-system = [ setuptools ];

  dependencies = [
    pytz
    requests
    simplejson
    stix2-patterns
  ];

  disabledTests = [
    # flaky tests
    "test_graph_equivalence_with_filesystem_source"
    "test_graph_similarity_with_filesystem_source"
    "test_object_similarity_prop_scores"
  ];

  pyproject = true;
  pythonImportsCheck = [ "stix2" ];

  meta = {
    description = "Produce and consume STIX 2 JSON content";
    homepage = "https://stix2.readthedocs.io/en/latest/";
    changelog = "https://github.com/oasis-open/cti-python-stix2/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ PapayaJackal ];
  };
})
