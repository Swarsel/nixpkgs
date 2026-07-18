{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  rsync,
}:

python3Packages.buildPythonApplication rec {
  pname = "remote-exec";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner = "remote-cli";
    repo = "remote";
    tag = "v${version}";
    hash = "sha256-rsboHJLOHXnpXtsVsvsfKsav8mSbloaq2lzZnU2pw6c=";
  };

  patches = [
    # relax install requirements
    # https://github.com/remote-cli/remote/pull/60.patch
    (fetchpatch {
      hash = "sha256-As0j+yY6LamhOCGFzvjUQoXFv46BN/tRBpvIS7r6DaI=";
      url = "https://github.com/remote-cli/remote/commit/a2073c30c7f576ad7ceb46e39f996de8d06bf186.patch";
    })
  ];

  # remove legacy endpoints, we use --multi now
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"mremote' '#"mremote'
  '';

  doCheck = true;

  nativeCheckInputs = [
    rsync
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ];

  dependencies = with python3Packages; [
    click
    pydantic
    toml
    watchdog
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # `watchdog` dependency does not correctly detect fsevents on darwin.
    # this only affects `remote --stream-changes`
    "test/test_file_changes.py"
  ];

  format = "setuptools";

  meta = {
    description = "Work with remote hosts seamlessly via rsync and ssh";
    homepage = "https://github.com/remote-cli/remote";
    changelog = "https://github.com/remote-cli/remote/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
