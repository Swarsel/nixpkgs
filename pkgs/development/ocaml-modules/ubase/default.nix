{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "ubase";
  version = "0.20";

  src = fetchFromGitHub {
    owner = "sanette";
    repo = "ubase";
    tag = version;
    sha256 = "sha256-zmYjWEk0r1h87RczCJu2tYlS79F/pAiBt16BplPmA7c=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.14.0";

  meta = {
    description = "Remove accents from utf8 strings";
    homepage = "https://github.com/sanette/ubase";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ mrdev023 ];
  };
}
