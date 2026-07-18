{
  lib,
  fetchFromGitHub,
  # dependencies
  beautifulsoup4,
  buildPythonPackage,
  httpx,
  pbkdf2,
  pillow,
  # build-system
  poetry-core,
  pyaes,
  # test dependencies
  pytestCheckHook,
  rsa,
}:

buildPythonPackage rec {
  pname = "audible";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "mkb79";
    repo = "Audible";
    tag = "v${version}";
    hash = "sha256-ILGhjuPIxpRxu/dVDmz531FUgMWosk4P+onPJltuPIs=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    pillow
    beautifulsoup4
    httpx
    pbkdf2
    pyaes
    rsa
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "audible" ];

  meta = {
    description = "A(Sync) Interface for internal Audible API written in pure Python";
    homepage = "https://github.com/mkb79/Audible";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ jvanbruegge ];
  };
}
