{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cron-converter,
  hatchling,
  pendulum,
  phonenumbers,
  pycountry,
  pydantic,
  pymongo,
  pytestCheckHook,
  python-ulid,
  pytz,
  semver,
  typing-extensions,
  tzdata,
}:

buildPythonPackage rec {
  pname = "pydantic-extra-types";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic-extra-types";
    tag = "v${version}";
    hash = "sha256-aXhlfDBCpk8h3F4gXAQ40fVKxsoFvkmfO/roaqrGxho=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.all;
  build-system = [ hatchling ];

  dependencies = [
    pydantic
    typing-extensions
  ];

  # PermissionError accessing '/etc/localtime'
  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [ "tests/test_pendulum_dt.py" ];

  disabledTests = [
    # https://github.com/pydantic/pydantic-extra-types/issues/346
    "test_json_schema"
  ];

  optional-dependencies = {
    all = [
      cron-converter
      pendulum
      phonenumbers
      pycountry
      pymongo
      python-ulid
      pytz
      semver
      tzdata
    ];

    cron = [ cron-converter ];
    pendulum = [ pendulum ];
    phonenumbers = [ phonenumbers ];
    pycountry = [ pycountry ];
    python_ulid = [ python-ulid ];
    semver = [ semver ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "pydantic_extra_types" ];

  meta = {
    description = "Extra Pydantic types";
    homepage = "https://github.com/pydantic/pydantic-extra-types";
    changelog = "https://github.com/pydantic/pydantic-extra-types/blob/${src.tag}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
