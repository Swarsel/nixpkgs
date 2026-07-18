{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "simplehound";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "robmarkcole";
    repo = "simplehound";
    rev = "v${version}";
    sha256 = "1b5m3xjmk0l6ynf0yvarplsfsslgklalfcib7sikxg3v5hiv9qwh";
  };

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    requests-mock
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "simplehound" ];

  meta = {
    description = "Python API for Sighthound";
    homepage = "https://github.com/robmarkcole/simplehound";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
