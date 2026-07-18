{
  lib,
  stdenv,
  appdirs,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  isPyPy,
  mock,
  psutil,
  pyftpdlib,
  pytestCheckHook,
  pythonAtLeast,
  pytz,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "fs";
  version = "2.4.16";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rpfH1RIT9LcLapWCklMCiQkN46fhWEHhCPvhRPBp0xM=";
  };

  postPatch = ''
    # https://github.com/PyFilesystem/pyfilesystem2/pull/591
    substituteInPlace tests/test_ftpfs.py \
      --replace ThreadedTestFTPd FtpdThreadWrapper
  '';

  env.LC_ALL = "en_US.utf-8";

  nativeCheckInputs = [
    pyftpdlib
    mock
    psutil
    pytestCheckHook
  ]
  ++ lib.optionals isPyPy [
    glibcLocales
  ];

  preCheck = ''
    HOME=$(mktemp -d)
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    setuptools
    six
    appdirs
    pytz
  ];

  # https://github.com/PyFilesystem/pyfilesystem2/issues/596
  disabled = pythonAtLeast "3.14";

  disabledTestPaths = [
    # Circular dependency with parameterized
    "tests/test_move.py"
    "tests/test_mirror.py"
    "tests/test_copy.py"
    # pyftpdlib removed tests from installation in 2.1.0, resulting in
    #     ModuleNotFoundError: No module named 'pyftpdlib.test'
    "tests/test_ftpfs.py"
    "tests/test_encoding.py" # fails under zfs normalization=formD
  ];

  disabledTests = [
    "user_data_repr"
    # https://github.com/PyFilesystem/pyfilesystem2/issues/568
    "test_remove"
    # Tests require network access
    "TestFTPFS"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    # remove if https://github.com/PyFilesystem/pyfilesystem2/issues/430#issue-707878112 resolved
    "test_ftpfs"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fs" ];

  meta = {
    description = "Filesystem abstraction";
    homepage = "https://github.com/PyFilesystem/pyfilesystem2";
    changelog = "https://github.com/PyFilesystem/pyfilesystem2/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    # https://github.com/PyFilesystem/pyfilesystem2/issues/577
    broken = lib.versionAtLeast setuptools.version "82";
  };
}
