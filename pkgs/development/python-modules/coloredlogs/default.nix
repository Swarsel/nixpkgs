{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  capturer,
  fetchpatch2,
  humanfriendly,
  mock,
  pytestCheckHook,
  setuptools,
  util-linux,
  verboselogs,
}:

buildPythonPackage rec {
  pname = "coloredlogs";
  version = "15.0.1";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-coloredlogs";
    rev = version;
    hash = "sha256-TodI2Wh8M0qMM2K5jzqlLmUKILa5+5qq4ByLttmAA7E=";
  };

  patches = [
    # https://github.com/xolox/python-coloredlogs/pull/120
    (fetchpatch2 {
      hash = "sha256-Z7MYzyoQBMLBS7c0r5zITuHpl5yn4Vg7Xf/CiG7jTSs=";
      name = "python313-compat.patch";
      url = "https://github.com/xolox/python-coloredlogs/commit/9d4f4020897fcf48d381de8e099dc29b53fc9531.patch?full_index=1";
    })
  ];

  # capturer is broken on darwin / py38, so we skip the test until a fix for
  # https://github.com/xolox/python-capturer/issues/10 is released.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    mock
    util-linux
    verboselogs
    capturer
  ];

  preCheck = ''
    # Required for the CLI test
    PATH=$PATH:$out/bin
  '';

  build-system = [ setuptools ];
  dependencies = [ humanfriendly ];

  disabledTests = [
    "test_plain_text_output_format"
    "test_auto_install"
  ];

  pyproject = true;
  pythonImportsCheck = [ "coloredlogs" ];

  meta = {
    description = "Colored stream handler for Python's logging module";
    homepage = "https://github.com/xolox/python-coloredlogs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
    mainProgram = "coloredlogs";
  };
}
