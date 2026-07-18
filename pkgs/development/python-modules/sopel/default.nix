{
  lib,
  buildPythonPackage,
  dnspython,
  fetchPypi,
  geoip2,
  importlib-metadata,
  ipython,
  isPyPy,
  packaging,
  praw,
  pyenchant,
  pytestCheckHook,
  pytz,
  setuptools,
  sqlalchemy,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "sopel";
  version = "8.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-16QDzsZCquAPH3FPyBjxeXGcvSdjYLZFTXN0ASneROU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools~=66.1" "setuptools"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    dnspython
    geoip2
    ipython
    praw
    pyenchant
    pytz
    sqlalchemy
    xmltodict
    importlib-metadata
    packaging
  ];

  disabled = isPyPy;

  disabledTests = [
    # requires network access
    "test_example_exchange_cmd_0"
    "test_example_exchange_cmd_1"
    "test_example_duck_0"
    "test_example_duck_1"
    "test_example_suggest_0"
    "test_example_suggest_1"
    "test_example_suggest_2"
    "test_example_tr2_0"
    "test_example_tr2_1"
    "test_example_tr2_2"
    "test_example_title_command_0"
    "test_example_wiktionary_0"
    "test_example_wiktionary_ety_0"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sopel" ];

  pythonRelaxDeps = [
    "sqlalchemy"
    "xmltodict"
  ];

  pythonRemoveDeps = [ "sopel-help" ];

  meta = {
    description = "Simple and extensible IRC bot";
    homepage = "https://sopel.chat";
    license = lib.licenses.efl20;
    maintainers = with lib.maintainers; [ mog ];
    mainProgram = "sopel";
  };
}
