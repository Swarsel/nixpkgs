{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  emoji,
  freezegun,
  pydantic,
  pytest-benchmark,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  syrupy,
  tzdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "ical";
  version = "13.3.0";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "ical";
    tag = finalAttrs.version;
    hash = "sha256-tyPD0z2wWND6b6TKe/uXH2N5HcaJifhV4gQS9GEAQxs=";
  };

  nativeCheckInputs = [
    emoji
    freezegun
    pytest-benchmark
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    tzdata
    pydantic
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "ical" ];

  meta = {
    description = "Library for handling iCalendar";
    homepage = "https://github.com/allenporter/ical";
    changelog = "https://github.com/allenporter/ical/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
