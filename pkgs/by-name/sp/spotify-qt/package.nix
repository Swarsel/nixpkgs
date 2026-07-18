{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  libxcb,
  procps,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spotify-qt";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "kraxarn";
    repo = "spotify-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gvSNgXUciO9U20iC9ZtyPPoFYLPzXjoRCIPkenYPe70=";
  };

  postPatch = ''
    substituteInPlace src/spotifyclient/helper.cpp \
      --replace-fail /usr/bin/ps ${lib.getExe' procps "ps"}
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    libxcb
    kdePackages.qtbase
    kdePackages.qtsvg
  ];

  cmakeFlags = [ (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "") ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/spotify-qt.app $out/Applications
    ln $out/Applications/spotify-qt.app/Contents/MacOS/spotify-qt $out/bin/spotify-qt
  '';

  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Lightweight unofficial Spotify client using Qt";
    homepage = "https://github.com/kraxarn/spotify-qt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ iivusly ];
    platforms = lib.platforms.unix;
    mainProgram = "spotify-qt";
  };
})
