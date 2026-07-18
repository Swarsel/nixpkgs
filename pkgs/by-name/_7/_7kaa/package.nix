{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  autoconf-archive,
  autoreconfHook,
  curl,
  enet,
  gccStdenv,
  gettext,
  libiconv,
  openal,
  pkg-config,
}:

let
  version = "2.15.6";

  musicVersion = lib.versions.majorMinor version;
  music = stdenv.mkDerivation {
    pname = "7kaa-music";
    version = musicVersion;

    src = fetchurl {
      url = "https://www.7kfans.com/downloads/7kaa-music-${musicVersion}.tar.bz2";
      hash = "sha256-sNdntuJXGaFPXzSpN0SoAi17wkr2YnW+5U38eIaVwcM=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';

    meta.license = lib.licenses.unfree;
  };
in
gccStdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "7kaa";

  src = fetchFromGitHub {
    owner = "the3dfxdude";
    repo = "7kaa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kkM+kFQ+tGHS5NrVPeDMRWFQb7waESt8xOLfFGaGdgo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [
    openal
    enet
    SDL2
    curl
    gettext
    libiconv
  ];

  postInstall = ''
    mkdir $out/share/7kaa/MUSIC
    cp -R ${music}/MUSIC $out/share/7kaa/
    cp ${music}/COPYING-Music.txt $out/share/7kaa/MUSIC
    cp ${music}/COPYING-Music.txt $out/share/doc/7kaa
  '';

  hardeningDisable = lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin) [
    "stackprotector"
  ];

  preAutoreconf = ''
    autoupdate
  '';

  # Multiplayer is auto-disabled for non-x86 system
  meta = {
    description = "GPL release of the Seven Kingdoms with multiplayer (available only on x86 platforms)";
    homepage = "https://www.7kfans.com";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ _1000101 ];
    platforms = lib.platforms.x86_64 ++ lib.platforms.aarch64;
  };
})
