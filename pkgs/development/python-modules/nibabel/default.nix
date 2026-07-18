{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  # optional-dependencies
  backports-zstd,
  buildPythonPackage,
  gitMinimal,
  h5py,
  # build-system
  hatch-vcs,
  hatchling,
  importlib-resources,
  indexed-gzip,
  matplotlib,
  # dependencies
  numpy,
  packaging,
  pillow,
  pydicom,
  pytest-doctestplus,
  pytest-httpserver,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  scipy,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "nibabel";
  version = "5.4.2";

  src = fetchFromGitHub {
    owner = "nipy";
    repo = "nibabel";
    tag = finalAttrs.version;
    hash = "sha256-QzkmSI0JGdIXLc3XSPZrGrBYSq98tLFrozNNopR/ytg=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    gitMinimal
    pytest-doctestplus
    pytest-httpserver
    pytest-xdist
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.all;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    numpy
    packaging
  ]
  ++ lib.optionals (pythonOlder "3.12") [ importlib-resources ]
  ++ lib.optionals (pythonOlder "3.13") [ typing-extensions ];

  optional-dependencies = lib.fix (self: {
    all = self.dicomfs ++ self.indexed_gzip ++ self.minc2 ++ self.spm ++ self.zstd;
    dicom = [ pydicom ];
    dicomfs = [ pillow ] ++ self.dicom;
    indexed_gzip = [ indexed-gzip ];
    minc2 = [ h5py ];
    spm = [ scipy ];
    viewers = [ matplotlib ];
    zstd = lib.optionals (pythonOlder "3.14") [ backports-zstd ];
  });

  pyproject = true;
  pythonImportsCheck = [ "nibabel" ];

  meta = {
    description = "Access a multitude of neuroimaging data formats";
    homepage = "https://nipy.org/nibabel";
    changelog = "https://github.com/nipy/nibabel/blob/${finalAttrs.version}/Changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashgillman ];
  };
})
