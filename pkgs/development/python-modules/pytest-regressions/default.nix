{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  pandas,
  pillow,
  pytest,
  pytest-datadir,
  pytestCheckHook,
  pyyaml,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-regressions";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "ESSS";
    repo = "pytest-regressions";
    tag = "v${version}";
    hash = "sha256-pqlRfpi5Z9b6zrvU6M1sNRz5ltZLAFiJITFvex7YqcE=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    matplotlib
    pandas
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools-scm ];

  dependencies = [
    pytest-datadir
    pyyaml
  ];

  disabledTests = [
    # https://github.com/ESSS/pytest-regressions/issues/225
    "test_categorical"
    "test_dataframe_with"
    "test_different_data_types"
    "test_nonrange_index"
    "test_string_array"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isi686 || stdenv.hostPlatform.isBigEndian) [
    # https://github.com/ESSS/pytest-regressions/issues/156
    # i686-linux not listed in the report, but seems to have this issue as well
    "test_different_data_types"
    "test_common_case" # not listed in the issue, but fails after the above is skipped
  ];

  optional-dependencies = {
    dataframe = [
      pandas
      numpy
    ];

    image = [
      numpy
      pillow
    ];

    num = [
      numpy
      pandas
    ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [
    "pytest_regressions"
    "pytest_regressions.plugin"
  ];

  meta = {
    description = "Pytest fixtures to write regression tests";

    longDescription = ''
      pytest-regressions makes it simple to test general data, images,
      files, and numeric tables by saving expected data in a data
      directory (courtesy of pytest-datadir) that can be used to verify
      that future runs produce the same data.
    '';

    homepage = "https://github.com/ESSS/pytest-regressions";
    changelog = "https://github.com/ESSS/pytest-regressions/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
