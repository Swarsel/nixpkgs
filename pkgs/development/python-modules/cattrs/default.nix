{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cbor2,
  hatch-vcs,
  hatchling,
  hypothesis,
  immutables,
  motor,
  msgpack,
  msgspec,
  orjson,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  tomlkit,
  typing-extensions,
  ujson,
}:

buildPythonPackage rec {
  pname = "cattrs";
  version = "25.3.0";

  src = fetchFromGitHub {
    owner = "python-attrs";
    repo = "cattrs";
    tag = "v${version}";
    hash = "sha256-6oQblSanvSZOMD5ossCP7fNjyxF54SRbU1cQrW1I5Ps=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "-l --benchmark-sort=fullname --benchmark-warmup=true --benchmark-warmup-iterations=5  --benchmark-group-by=fullname" ""
    substituteInPlace tests/test_preconf.py \
      --replace-fail "from orjson import dumps as orjson_dumps" "" \
      --replace-fail "from orjson import loads as orjson_loads" ""
  '';

  nativeCheckInputs = [
    cbor2
    hypothesis
    immutables
    motor
    msgpack
    msgspec
    orjson
    pytest-xdist
    pytestCheckHook
    pyyaml
    tomlkit
    ujson
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    attrs
    typing-extensions
  ];

  disabledTestPaths = [
    # Don't run benchmarking tests
    "bench"
  ];

  disabledTests = [
    # orjson is not available as it requires Rust nightly features to compile its requirements
    "test_orjson"
    # msgspec causes a segmentation fault for some reason
    "test_simple_classes"
    "test_msgspec_json_converter"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # https://github.com/python-attrs/cattrs/pull/543
    "test_unstructure_deeply_nested_generics_list"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cattr" ];

  meta = {
    description = "Python custom class converters for attrs";
    homepage = "https://github.com/python-attrs/cattrs";
    changelog = "https://github.com/python-attrs/cattrs/blob/${src.tag}/HISTORY.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
