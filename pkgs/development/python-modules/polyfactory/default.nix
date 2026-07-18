{
  lib,
  fetchFromGitHub,
  # dependencies
  aiosqlite,
  buildPythonPackage,
  email-validator,
  faker,
  # build-system
  hatchling,
  hypothesis,
  msgspec,
  pydantic,
  pymongo,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  sqlalchemy,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "polyfactory";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "litestar-org";
    repo = "polyfactory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KcruZTaCUHalfQtaJmj3BHF220Ccd3LKn+my/LuYroI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiosqlite
    email-validator
    faker
    hypothesis
    msgspec
    pydantic
    pymongo
    sqlalchemy
    typing-extensions
  ];

  disabledTestPaths = [
    # Requires unpackaged 'beanie'
    "tests/test_beanie_factory.py"
  ];

  disabledTests = [
    # Unsupported type: LiteralAlias
    "test_type_alias"
    # Unsupported type: 'JsonValue' on field '' from class RecursiveTypeModelFactory.
    "test_recursive_type_annotation"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # AttributeError: 'Foo' object has no attribute 'set_field'
    "test_other_basic_types"

    # KeyError: 'foo_field'
    "test_with_nested_struct"

    # AttributeError: 'Foo' object has no attribute 'unset'
    "test_msgspec_types"

    # Failed: DID NOT RAISE <class 'polyfactory.exceptions.ParameterException'>
    "test_datetime_constraints"

    # assert <msgspec._core.Field object at 0x7ffff34794c0> == 10
    "test_use_default_with_callable_default"
  ];

  enabledTestPaths = [
    "tests/test_msgspec_factory.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "polyfactory" ];

  meta = {
    description = "Simple and powerful factories for mock data generation";
    homepage = "https://polyfactory.litestar.dev/";
    changelog = "https://github.com/litestar-org/polyfactory/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
  };
})
