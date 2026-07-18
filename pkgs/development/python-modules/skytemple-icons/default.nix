{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "skytemple-icons";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-icons";
    rev = version;
    sha256 = "0wagdvzks9irdl5lj8sfqkkvfwwmdpvjyzx6424shvpp5mk28dcv";
  };

  doCheck = false; # there are no tests
  format = "setuptools";
  pythonImportsCheck = [ "skytemple_icons" ];

  meta = {
    description = "Icons for SkyTemple";
    homepage = "https://github.com/SkyTemple/skytemple-icons";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
