{
  lib,
  aioredis,
  apscheduler,
  buildPythonPackage,
  ephem,
  fetchPypi,
  hiredis,
  pytestCheckHook,
  pythonAtLeast,
  pytz,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "automate-home";
  version = "0.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-41qd+KPSrOrczkovwXht3irbcYlYehBZ1HZ44yZe4cM=";
  };

  postPatch = ''
    # Rename pyephem, https://github.com/majamassarini/automate-home/pull/3
    substituteInPlace setup.py \
      --replace-fail "pyephem" "ephem" \
      --replace-fail "aioredis==1.3.1" "aioredis"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    apscheduler
    hiredis
    aioredis
    ephem
    pytz
    pyyaml
  ];

  # Typing issue
  disabled = pythonAtLeast "3.12";
  pyproject = true;
  pythonImportsCheck = [ "home" ];

  meta = {
    description = "Python module to automate (home) devices";
    homepage = "https://github.com/majamassarini/automate-home";
    changelog = "https://github.com/majamassarini/automate-home/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
