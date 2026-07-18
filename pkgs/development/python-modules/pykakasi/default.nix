{
  lib,
  buildPythonPackage,
  deprecated,
  fetchFromCodeberg,
  jaconv,
  py-cpuinfo,
  pytest-benchmark,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pykakasi";
  version = "2.3.0";

  src = fetchFromCodeberg {
    owner = "miurahr";
    repo = "pykakasi";
    tag = "v${version}";
    hash = "sha256-b2lYYdg1RW1xRD3hym7o1EnxzN/U5txVTWRifwZn3k0=";
  };

  nativeCheckInputs = [
    py-cpuinfo
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    jaconv
    deprecated
  ];

  disabledTests = [
    # Assertion error
    "test_aozora"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "pykakasi" ];

  meta = {
    description = "Python converter for Japanese Kana-kanji sentences into Kana-Roman";
    homepage = "https://codeberg.org/miurahr/pykakasi";
    changelog = "https://codeberg.org/miurahr/pykakasi/src/tag/v${version}/CHANGELOG.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "kakasi";
  };
}
