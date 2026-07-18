{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gawk,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "cfs-zen-tweaks";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "igo95862";
    repo = "cfs-zen-tweaks";
    rev = version;
    hash = "sha256-E3sNWWXm0NEqLCzFccd/nfYby+/b/MVjIHeGlDxV1W4=";
  };

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    substituteInPlace set-cfs-zen-tweaks.sh \
      --replace '$(gawk' '$(${gawk}/bin/gawk'
  '';

  preFixup = ''
    chmod +x $out/lib/cfs-zen-tweaks/set-cfs-zen-tweaks.sh
  '';

  meta = {
    description = "Tweak Linux CPU scheduler for desktop responsiveness";
    homepage = "https://github.com/igo95862/cfs-zen-tweaks";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.linux;
  };
}
