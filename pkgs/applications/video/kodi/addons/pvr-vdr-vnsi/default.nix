{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libGL,
  rel,
}:
buildKodiBinaryAddon rec {
  pname = "pvr-vdr-vnsi";
  version = "21.1.3";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.vdr.vnsi";
    rev = "${version}-${rel}";
    sha256 = "sha256-V/ICEK006Zs4mipywAbRl8ZdezsprCgdC2WYtc/cAAY=";
  };

  extraBuildInputs = [ libGL ];
  namespace = "pvr.vdr.vnsi";

  meta = {
    description = "Kodi's VDR VNSI PVR client addon";
    homepage = "https://github.com/kodi-pvr/pvr.vdr.vnsi";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
