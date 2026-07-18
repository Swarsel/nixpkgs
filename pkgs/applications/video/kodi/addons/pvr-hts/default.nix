{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  fetchpatch2,
  rel,
}:
buildKodiBinaryAddon rec {
  pname = "pvr-hts";
  version = "21.2.6";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.hts";
    rev = "${version}-${rel}";
    sha256 = "sha256-opxNgin+Sz/Nb9IGZ+OFrCzbDc4FXl2LaNKUu5LAgFM=";
  };

  patches = [
    # fix gcc-15 compat. See https://github.com/kodi-pvr/pvr.hts/pull/693
    (fetchpatch2 {
      hash = "sha256-GgdEQUwwebQVjsEJAX9V7NRe954HCNMggNUcik8j+lU=";
      url = "https://github.com/kodi-pvr/pvr.hts/commit/b8fb7f6cbe9e3e9ea2737dc465a70fb4bb0951eb.patch?full_index=1";
    })
  ];

  namespace = "pvr.hts";

  meta = {
    description = "Kodi's Tvheadend HTSP client addon";
    homepage = "https://github.com/kodi-pvr/pvr.hts";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
