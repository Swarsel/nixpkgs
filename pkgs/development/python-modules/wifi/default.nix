{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pbkdf2,
  pytestCheckHook,
  wirelesstools,
}:

buildPythonPackage rec {
  pname = "wifi";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "rockymeza";
    repo = "wifi";
    rev = "v${version}";
    hash = "sha256-scg/DvApvyQZtzDgkHFJzf9gCRfJgBvZ64CG/c2Cx8E=";
  };

  postPatch = ''
    substituteInPlace wifi/scan.py \
      --replace "/sbin/iwlist" "${wirelesstools}/bin/iwlist"
  '';

  propagatedBuildInputs = [ pbkdf2 ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "wifi" ];

  meta = {
    description = "Provides a command line wrapper for iwlist and /etc/network/interfaces";
    homepage = "https://github.com/rockymeza/wifi";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ rhoriguchi ];
    mainProgram = "wifi";
  };
}
