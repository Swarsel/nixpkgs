{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  poetry-core,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "bitvector-for-humans";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "JnyJny";
    repo = "bitvector";
    rev = version;
    hash = "sha256-GVTRD83tq/Hea53US4drOD5ruoYCLTVd24aZOSdDsSo=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-BG3IpDMys88RtkPOd58CWpRWKKzbNe5kV+64hWjtecE=";
      # https://github.com/JnyJny/bitvector/pull/1
      name = "fix-poetry-core.patch";
      url = "https://github.com/JnyJny/bitvector/commit/e5777f2425895ed854e54bed2ed9d993f6feaf2f.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "bitvector" ];

  meta = {
    description = "This simple bit vector implementation aims to make addressing single bits a little less fiddly";
    homepage = "https://github.com/JnyJny/bitvector";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];
  };
}
