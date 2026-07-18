{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  pycryptodome,
  requests,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "micloud";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "Squachen";
    repo = "micloud";
    rev = "v_${version}";
    hash = "sha256-IsNXFs1N+rKwqve2Pjp+wRTZCxHF4acEo6KyhsSKuqI=";
  };

  propagatedBuildInputs = [
    click
    pycryptodome
    requests
    tzlocal
  ];

  # tests require credentials
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "micloud" ];

  meta = {
    description = "Xiaomi cloud connect library";
    homepage = "https://github.com/Squachen/micloud";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "micloud";
  };
}
