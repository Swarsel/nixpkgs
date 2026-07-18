{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  # optional/test dependencies
  gdcm,
  numpy,
  pillow,
  pydicom,
  pyfakefs,
  pyjpegls,
  pylibjpeg,
  pylibjpeg-libjpeg,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  # Pydicom needs pydicom-data to run some tests. If these files aren't downloaded
  # before the package creation, it'll try to download during the checkPhase.
  test_data = fetchFromGitHub {
    hash = "sha256-ji7SppKdiszaXs8yCSIPkJj4Ld++XWNw9FuxLoFLfFo=";
    owner = "pydicom";
    repo = "pydicom-data";
    rev = "8da482f208401d63cd63f3f4efc41b6856ef36c7";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "pydicom";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "pydicom";
    repo = "pydicom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d7fFsNKzUoGUDg9E6KVHq64g7p8QzIAAEIk3vLQ+rQ0=";
  };

  doCheck = false; # circular dependency

  nativeCheckInputs = [
    pytestCheckHook
    pyfakefs
    writableTmpDirAsHomeHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.pixeldata;

  # Setting $HOME to prevent pytest to try to create a folder inside
  # /homeless-shelter which is read-only.
  # Linking pydicom-data dicom files to $HOME/.pydicom/data
  preCheck = ''
    mkdir -p $HOME/.pydicom/
    ln -s ${test_data}/data_store/data $HOME/.pydicom/data
  '';

  build-system = [ flit-core ];

  dependencies = [
    numpy
  ];

  disabledTests = [
    # tries to remove a dicom inside $HOME/.pydicom/data/ and download it again
    "test_fetch_data_files"

    # test_reference_expl{,_binary}[parametric_map_float.dcm] tries to download that file for some reason even though it's present in test-data
    "test_reference_expl"
    "test_reference_expl_binary"

    # slight error in regex matching
    "test_no_decoders_raises"
    "test_deepcopy_bufferedreader_raises"
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    # https://github.com/pydicom/pydicom/issues/1386
    "test_array"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # flaky, hard to reproduce failure outside hydra
    "test_time_check"
  ];

  optional-dependencies = {
    pixeldata = [
      pillow
      pyjpegls
      pylibjpeg
      pylibjpeg-libjpeg
      gdcm
    ]
    ++ pylibjpeg.optional-dependencies.openjpeg
    ++ pylibjpeg.optional-dependencies.rle;
  };

  pyproject = true;
  pythonImportsCheck = [ "pydicom" ];
  passthru.pydicom-data = test_data;

  passthru.tests.pytest = pydicom.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Python package for working with DICOM files";
    homepage = "https://pydicom.github.io";
    changelog = "https://github.com/pydicom/pydicom/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "pydicom";
  };
})
