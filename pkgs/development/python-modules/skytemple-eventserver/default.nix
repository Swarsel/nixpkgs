{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "skytemple-eventserver";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-eventserver";
    rev = version;
    hash = "sha256-PWLGPORNprTfG+jgXI1sxyVkRTwSEib4SZhPdOBchwE=";
  };

  doCheck = false; # there are no tests
  format = "setuptools";
  pythonImportsCheck = [ "skytemple_eventserver" ];

  meta = {
    description = "Websocket server that emits SkyTemple UI events";
    homepage = "https://github.com/SkyTemple/skytemple-eventserver";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
