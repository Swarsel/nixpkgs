{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  click,
  # build-system
  flit-core,
  # tests
  jsonpickle,
  numpy,
  # dependencies
  orderly-set,
  orjson,
  pandas,
  polars,
  pydantic,
  pytestCheckHook,
  python-dateutil,
  pytz,
  pyyaml,
  tomli-w,
  uuid6,
}:

buildPythonPackage rec {
  pname = "deepdiff";
  version = "8.6.2";

  src = fetchFromGitHub {
    owner = "qlustered";
    repo = "deepdiff";
    tag = version;
    hash = "sha256-/XRPP8O2ykoXwOZ2ou/7Yoa1x7t45dCx6G3aq30o3Wc=";
  };

  nativeCheckInputs = [
    jsonpickle
    numpy
    pandas
    polars
    pydantic
    pytestCheckHook
    python-dateutil
    pytz
    tomli-w
    uuid6
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    flit-core
  ];

  dependencies = [
    orderly-set
  ];

  disabledTests = [
    # Require pytest-benchmark
    "test_cache_deeply_nested_a1"
    "test_lfu"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Times out on darwin in Hydra
    "test_repeated_timer"
    # Requires too much RAM and fails only on Darwin from some reason.
    "test_restricted_unpickler_memory_exhaustion_cve"
  ];

  optional-dependencies = {
    cli = [
      click
      pyyaml
    ];

    optimize = [
      orjson
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "deepdiff" ];

  meta = {
    description = "Deep Difference and Search of any Python object/data";
    homepage = "https://github.com/qlustered/deepdiff";
    changelog = "https://github.com/qlustered/deepdiff/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mic92
      doronbehar
    ];

    mainProgram = "deep";
  };
}
