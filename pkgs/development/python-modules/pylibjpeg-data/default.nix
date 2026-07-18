{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
}:

buildPythonPackage {
  pname = "pylibjpeg-data";
  version = "unstable-2024-03-28";

  src = fetchFromGitHub {
    owner = "pydicom";
    repo = "pylibjpeg-data";
    rev = "8253566715800a7fc3d4d949abab102c8172bca0";
    hash = "sha256-TzhiZ4LCFZX75h3YRrEFO5kRVc5VwTOJd+1VFW3LsaQ=";
  };

  doCheck = false; # no tests
  build-system = [ flit-core ];
  pyproject = true;

  pythonImportsCheck = [
    "ljdata"
    "ljdata.ds"
    "ljdata.jpg"
  ];

  meta = {
    description = "JPEG and DICOM data used for testing pylibjpeg";
    homepage = "https://github.com/pydicom/pylibjpeg-data";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
