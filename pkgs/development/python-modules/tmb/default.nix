{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
}:

buildPythonPackage rec {
  pname = "tmb";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "alemuro";
    repo = "tmb";
    rev = version;
    hash = "sha256-XuRhRmeTXAplb14UwISyzaqEIrFeg8/aCdMxUccMUos=";
  };

  propagatedBuildInputs = [ requests ];
  env.VERSION = version;
  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "tmb" ];

  meta = {
    description = "Python library that interacts with TMB API";
    homepage = "https://github.com/alemuro/tmb";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
