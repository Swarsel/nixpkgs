{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  jsonable,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mwtypes";
  version = "0.4.0";

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-PgcGUk/27cAIvzfLvRoVX2vHOCab59m+4bciDPmtlW8=";
  };

  patches = [
    # https://github.com/mediawiki-utilities/python-mwtypes/pull/6
    (fetchpatch2 {
      hash = "sha256-jh1uEqqhIK2DyNvVN0XYGM7BXTmypnoC4VoB0V+9JmE=";
      name = "nose-to-pytest.patch";
      url = "https://github.com/mediawiki-utilities/python-mwtypes/commit/58d7f59e4927aaa6278f84576794df713c673058.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ jsonable ];
  # Even with 7z included, this test does not pass
  disabledTests = [ "test_open_file" ];
  pyproject = true;
  pythonImportsCheck = [ "mwtypes" ];

  meta = {
    description = "Set of classes for working with MediaWiki data types";
    homepage = "https://github.com/mediawiki-utilities/python-mwtypes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
