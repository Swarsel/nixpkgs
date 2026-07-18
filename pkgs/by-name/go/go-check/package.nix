{
  lib,
  fetchFromGitLab,
  buildGoModule,
}:

buildGoModule rec {
  pname = "check";
  version = "unstable-2018-12-24";

  src = fetchFromGitLab {
    inherit rev;
    owner = "opennota";
    repo = "check";
    hash = "sha256-u8U/62LZEn1ffwdGsUCGam4HAk7b2LetomCLZzHuuas=";
  };

  vendorHash = "sha256-DyysiVYFpncmyCzlHIOEtWlCMpm90AC3gdItI9WinSo=";
  rev = "ccaba434e62accd51209476ad093810bd27ec150";

  meta = {
    description = "Set of utilities for checking Go sources";
    homepage = "https://gitlab.com/opennota/check";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ kalbasit ];
  };
}
