{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pytz,
  simplejson,
  types-python-dateutil,
  tzdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "arrow";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "crsmithdev";
    repo = "arrow";
    tag = finalAttrs.version;
    hash = "sha256-nK78Lo+7eitB+RS7BZkM+BNudviirAowc4a1uQdLC0w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    pytz
    simplejson
  ];

  build-system = [ flit-core ];

  dependencies = [
    python-dateutil
    types-python-dateutil
    tzdata
  ];

  pyproject = true;
  # ParserError: Could not parse timezone expression "America/Nuuk"
  #disabledTests = [ "test_parse_tz_name_zzz" ];
  pythonImportsCheck = [ "arrow" ];

  meta = {
    description = "Python library for date manipulation";
    homepage = "https://github.com/crsmithdev/arrow";
    changelog = "https://github.com/arrow-py/arrow/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
})
