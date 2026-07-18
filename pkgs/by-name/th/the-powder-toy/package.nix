{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bzip2,
  copyDesktopItems,
  curl,
  fftwFloat,
  jsoncpp,
  libpng,
  libx11,
  lua5_2,
  luajit,
  meson,
  ninja,
  pkg-config,
  python3,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "the-powder-toy";
  version = "99.5.394";

  src = fetchFromGitHub {
    owner = "The-Powder-Toy";
    repo = "The-Powder-Toy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ejkWIxlS6J9DHw/XNmEC94oc0xmqvj+hFu3TBPyCqwg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems;

  buildInputs = [
    bzip2
    curl
    fftwFloat
    jsoncpp
    libpng
    libx11
    lua5_2
    luajit
    SDL2
    zlib
  ];

  mesonFlags = [ "-Dworkaround_elusive_bzip2=false" ];

  installPhase = ''
    runHook preInstall

    install -Dm 755 powder $out/bin/powder

    mkdir -p $out/share
    mv ../resources $out/share

    runHook postInstall
  '';

  desktopItems = [ "resources/powder.desktop" ];

  meta = {
    description = "Free 2D physics sandbox game";
    homepage = "https://powdertoy.co.uk/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      siraben
    ];

    platforms = lib.platforms.unix;
    mainProgram = "powder";
  };
})
