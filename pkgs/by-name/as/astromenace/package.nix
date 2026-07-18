{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  fetchpatch,
  fontconfig,
  freealut,
  freetype,
  libGL,
  libGLU,
  libice,
  libogg,
  libvorbis,
  libx11,
  libxinerama,
  makeWrapper,
  ninja,
  openal,
  runtimeShell,
}:

stdenv.mkDerivation rec {
  pname = "astromenace";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "viewizard";
    repo = "astromenace";
    rev = "v${version}";
    hash = "sha256-W6d+8iw7/r2qJbE75U7egxqvK2HXaKzk+GtnspZRAxk=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-pkmTVR86vS+KCICxAp+d7upNWVnSNxwdKmxnbtqIvgU=";
      url = "https://src.fedoraproject.org/rpms/astromenace/raw/5e6bc02d115a53007dc47ef8223d8eaa25607588/f/astromenace-gcc13.patch";
    })

    (fetchpatch {
      hash = "sha256-TQVcnDrKBFvcyYhWeeEQSRjuirtJ7wYFQV+f3bHikdA=";
      name = "cmake-4.patch";
      url = "https://github.com/viewizard/astromenace/commit/eb42ddb1e86a3e67787bfd5e33ff2afdd6307142.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
  ];

  buildInputs = [
    libice
    libx11
    libxinerama
    libGLU
    libGL
    SDL2
    openal
    fontconfig
    freealut
    freetype
    libogg
    libvorbis
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/astromenace
    install -Dm644 gamedata.vfs $out/share/astromenace/gamedata.vfs
    install -Dm755 astromenace $out/bin/astromenace
    wrapProgram $out/bin/astromenace \
      --add-flags "--dir=$out/share/astromenace"
    runHook postInstall
  '';

  meta = {
    description = "Hardcore 3D space shooter with spaceship upgrade possibilities";
    homepage = "https://www.viewizard.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
    mainProgram = "astromenace";
  };
}
