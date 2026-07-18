{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pydicom,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dicom-numpy";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "innolitics";
    repo = "dicom-numpy";
    tag = "v${version}";
    hash = "sha256-pgmREQlstr0GY2ThIWt4hbcSWmaNWgkr2gO4PSgGHqE=";
  };

  postPatch = ''
    substituteInPlace dicom_numpy/zip_archive.py \
      --replace-fail "pydicom.read_file" "pydicom.dcmread"
  '';

  propagatedBuildInputs = [
    numpy
    pydicom
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "dicom_numpy" ];

  meta = {
    description = "Read DICOM files into Numpy arrays";
    homepage = "https://github.com/innolitics/dicom-numpy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
