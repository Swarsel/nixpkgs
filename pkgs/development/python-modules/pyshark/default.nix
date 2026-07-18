{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  appdirs,
  buildPythonPackage,
  # patches
  fetchpatch,
  lxml,
  packaging,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  replaceVars,
  # build-system
  setuptools,
  termcolor,
  wireshark-cli,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyshark";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "KimiNewt";
    repo = "pyshark";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kzJDzUK6zknUyXPdKc4zMvWim4C5NQCSJSS45HI6hKM=";
  };

  patches = [
    # fixes capture test
    (fetchpatch {
      hash = "sha256-Ti7cwRyYSbF4a4pEEV9FntNevkV/JVXNqACQWzoma7g=";
      url = "https://github.com/KimiNewt/pyshark/commit/7142c5bf88abcd4c65c81052a00226d6155dda42.patch";
    })
    # fixes tests that failed related to elastic-mapping
    # remove fix if this is ever merged upstream
    (fetchpatch {
      hash = "sha256-fpgiBHcfS/TGYIB65ioZJrWUuDIrLxxXqGVJ9y18b2w=";
      url = "https://github.com/KimiNewt/pyshark/commit/0e1d8d0e06108f2887c3147c93049de63b475f8a.patch";
    })
    (replaceVars ./hardcode-tshark-path.patch {
      tshark = lib.getExe' wireshark-cli "tshark";
    })
    # Compat for Python 3.14 asyncio changes
    ./py314-compat.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    appdirs
    lxml
    packaging
    termcolor
  ];

  disabledTests = [
    # flaky
    # KeyError: 'Packet of index 0 does not exist in capture'
    "test_getting_packet_summary"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # _pickle.PicklingError: logger cannot be pickled
    "test_iterate_empty_psml_capture"
    # configparser.NoSectionError: No section: 'tshark'
    # Path is mocked, and yet...
    "test_get_tshark_path"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # fails on darwin
    # _pickle.PicklingError: logger cannot be pickled
    "test_iterate_empty_psml_capture"
  ];

  enabledTestPaths = [ "../tests/" ];
  # `stripLen` does not seem to work here
  patchFlags = [ "-p2" ];
  pyproject = true;
  pythonImportsCheck = [ "pyshark" ];
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Python wrapper for tshark, allowing Python packet parsing using Wireshark dissectors";
    homepage = "https://github.com/KimiNewt/pyshark/";
    changelog = "https://github.com/KimiNewt/pyshark/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
