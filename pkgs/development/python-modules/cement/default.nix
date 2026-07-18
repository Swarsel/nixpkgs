{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  colorlog,
  fetchpatch,
  jinja2,
  mock,
  pdm-backend,
  pylibmc,
  pystache,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  redis,
  requests,
  tabulate,
  watchdog,
}:

buildPythonPackage rec {
  pname = "cement";
  version = "3.0.14";

  src = fetchFromGitHub {
    owner = "datafolklabs";
    repo = "cement";
    tag = version;
    hash = "sha256-hZ9kKQmMomjy5nnHKQ2RWB+6vIID8XMn3qutg0wCBq8=";
  };

  patches = [
    # Upstream PR: https://github.com/datafolklabs/cement/pull/759
    (fetchpatch {
      hash = "sha256-GUHAYp2oxHo1vo1gWnOyCAaNyBBIQM1ixC1p+Yc+Fsc=";
      includes = [ "tests/*" ];
      name = "python-3.14.patch";
      url = "https://github.com/datafolklabs/cement/commit/8b038170d82be7dbd283d72b9c5db3cceec7163b.patch";
    })
  ];

  # Tests are failing on Darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    mock
    pytest-cov-stub
    pytestCheckHook
    requests
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ pdm-backend ];

  disabledTestPaths = [
    # Tests require network access
    "tests/ext/test_ext_memcached.py"
    "tests/ext/test_ext_redis.py"
    "tests/ext/test_ext_smtp.py"
  ];

  disabledTests = [
    # Test only works with the source from PyPI
    "test_get_version"
  ];

  optional-dependencies = {
    cli = [
      jinja2
      pyyaml
    ];

    colorlog = [ colorlog ];
    generate = [ pyyaml ];
    jinja2 = [ jinja2 ];
    memcached = [ pylibmc ];
    mustache = [ pystache ];
    redis = [ redis ];
    tabulate = [ tabulate ];
    watchdog = [ watchdog ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cement" ];

  meta = {
    description = "CLI Application Framework for Python";
    homepage = "https://builtoncement.com/";
    changelog = "https://github.com/datafolklabs/cement/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eqyiel ];
    mainProgram = "cement";
  };
}
