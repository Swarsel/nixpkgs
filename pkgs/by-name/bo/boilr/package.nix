{
  lib,
  stdenv,
  fetchFromGitHub,
  clangStdenv,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  speechd-minimal,
  wayland,
}:
let
  rpathLibs = [
    speechd-minimal
    openssl
    gtk3
    libxkbcommon
    libGL

    # WINIT_UNIX_BACKEND=wayland
    wayland

    # WINIT_UNIX_BACKEND=x11
    libxcursor
    libxrandr
    libxi
    libx11
    libxcb
  ];
in
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } rec {
  pname = "BoilR";
  version = "1.9.6";

  src = fetchFromGitHub {
    owner = "PhilipK";
    repo = "BoilR";
    tag = "v.${version}";
    hash = "sha256-qCY/I3ACrs5mWpgN+xmWi42rF9Mzqxxce2DIA+R1RNs=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = rpathLibs;
  cargoHash = "sha256-9B2NcFO/Bj553yaOMi7oBZJTFtCQmBnJkU9nK+vjThU=";

  postInstall = ''
    patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/boilr
    install -Dpm 0644 flatpak/io.github.philipk.boilr.desktop $out/share/applications/boilr.desktop
    install -Dpm 0644 resources/io.github.philipk.boilr.png -t $out/share/icons/hicolor/32x32/apps
  '';

  dontPatchELF = true;

  meta = {
    description = "Automatically adds (almost) all your games to your Steam library (including image art)";
    homepage = "https://github.com/PhilipK/BoilR";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ foolnotion ];
    platforms = lib.platforms.linux;
    mainProgram = "boilr";
  };
}
