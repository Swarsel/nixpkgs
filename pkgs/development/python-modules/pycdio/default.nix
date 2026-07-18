{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libcdio,
  libiconv,
  nix-update-script,
  pkg-config,
  pytestCheckHook,
  setuptools,
  swig,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycdio";
  version = "2.1.1-unstable-2024-02-26";

  src = fetchFromGitHub {
    owner = "rocky";
    repo = "pycdio";
    rev = "806c6a2eeeeb546055ce2ac9a0ae6a14ea53ae35"; # no tag for this version (yet)
    hash = "sha256-bOm82mBUIaw4BGHj3Y24Fv5+RfAew+Ma1u4QENXoRiU=";
  };

  postPatch = ''
    substituteInPlace {data,test}/isofs-m1.cue \
      --replace-fail "ISOFS-M1.BIN" "isofs-m1.bin"
  '';

  nativeBuildInputs = [
    pkg-config
    swig
  ];

  buildInputs = [
    libcdio
    libiconv
  ];

  preConfigure = ''
    patchShebangs .
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # Test are depending on image files that are not there
    "test_bincue"
    "test_cdda"
  ];

  enabledTestPaths = [ "test/test-*.py" ];
  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Wrapper around libcdio (CD Input and Control library)";
    homepage = "https://www.gnu.org/software/libcdio/";
    changelog = "https://github.com/rocky/pycdio/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
