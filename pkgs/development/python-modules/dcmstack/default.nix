{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nibabel,
  pint,
  pydicom,
  pylibjpeg,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "dcmstack";
  version = "0.9-unstable-2024-12-05";

  src = fetchFromGitHub {
    owner = "moloney";
    repo = "dcmstack";
    rev = "68575996c8956152865e3598b15f621d7c803a96";
    hash = "sha256-QXnBtlXkxYDJFdjiqCoEuBMcHnq+87YmHX8j5EPW7HU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    nibabel
    pydicom
    pylibjpeg
    pint
  ];

  disabledTestPaths = [
    # AttributeError: 'TestNitoolCli' object has no attribute 'out_dir'
    "test/test_cli.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dcmstack" ];

  meta = {
    description = "DICOM to Nifti conversion preserving metadata";
    homepage = "https://github.com/moloney/dcmstack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
