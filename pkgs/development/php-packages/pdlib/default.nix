{
  lib,
  fetchFromGitHub,
  buildPecl,
  dlib,
  pkg-config,
}:
let
  pname = "pdlib";
  version = "1.1.0";
in
buildPecl {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "goodspb";
    repo = "pdlib";
    rev = "v${version}";
    sha256 = "sha256-AKZ3F2XzEQCeZkacSXBinxeGQrHBmqjP7mDGQ3RBAiE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ (dlib.override { guiSupport = true; }) ];

  meta = {
    description = "PHP extension for Dlib";
    homepage = "https://github.com/goodspb/pdlib";
    license = with lib.licenses; [ mit ];
    teams = [ lib.teams.php ];
  };
}
