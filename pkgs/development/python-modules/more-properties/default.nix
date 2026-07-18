{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "more-properties";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "madman-bob";
    repo = "python-more-properties";
    tag = version;
    hash = "sha256-dKG97rw5IG19m7u3ZDBM2yGScL5cFaKBvGZxPVJaUTE=";
  };

  postPatch = ''
    mv pypi_upload/setup.py .
    substituteInPlace setup.py \
      --replace-fail "project_root = Path(__file__).parents[1]" "project_root = Path(__file__).parents[0]"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  # All tests are failing with:
  # AssertionError: None != 'The type of the None singleton.'
  disabled = pythonAtLeast "3.13";
  pyproject = true;
  pythonImportsCheck = [ "more_properties" ];

  pythonRemoveDeps = [
    # dataclasses is included in Python since 3.7
    "dataclasses"
  ];

  meta = {
    description = "Collection of property variants";
    homepage = "https://github.com/madman-bob/python-more-properties";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
