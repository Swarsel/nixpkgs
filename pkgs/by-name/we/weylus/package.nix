{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  cmake,
  dbus,
  ffmpeg,
  git,
  gst_all_1,
  libdrm,
  libtool,
  libva,
  libxcomposite,
  libxcursor,
  libxext,
  libxfixes,
  libxft,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxtst,
  libxv,
  makeWrapper,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  typescript,
  wayland,
  x264,
}:

rustPlatform.buildRustPackage {
  pname = "weylus";
  version = "unstable-2025-10-08";

  src = fetchFromGitHub {
    owner = "H-M-H";
    repo = "weylus";
    rev = "56e29ecbde3a4aba994a9df047b5398feb447c1b";
    hash = "sha256-dHdgWrygSXqKf9fpYRVDj+Ql97Or/kjBfN/mECy2ipc=";
  };

  nativeBuildInputs = [
    cmake
    git
    typescript
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    autoconf
    libtool
  ];

  buildInputs = [
    ffmpeg
    x264
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    libva
    gst_all_1.gst-plugins-base
    libxext
    libxft
    libxinerama
    libxcursor
    libxrender
    libxfixes
    libxtst
    libxrandr
    libxcomposite
    libxi
    libxv
    pango
    libdrm
    wayland
    libxkbcommon
  ];

  cargoHash = "sha256-Mx8/zMG36qztbFYgqC7SB75bf8T0NkYQA+2Hs9/pnjk=";

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-incompatible-pointer-types"
    ];
  };

  postInstall = ''
    install -vDm755 weylus.desktop $out/share/applications/weylus.desktop
  '';

  postFixup =
    let
      GST_PLUGIN_PATH = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
        gst_all_1.gst-plugins-base
        pipewire
      ];
    in
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/weylus --prefix GST_PLUGIN_PATH : ${GST_PLUGIN_PATH}
    '';

  cargoBuildFlags = [ "--features=ffmpeg-system" ];
  cargoTestFlags = [ "--features=ffmpeg-system" ];

  meta = {
    description = "Use your tablet as graphic tablet/touch screen on your computer";
    homepage = "https://github.com/H-M-H/Weylus";
    license = with lib.licenses; [ agpl3Only ];
    maintainers = [ ];
    mainProgram = "weylus";
  };
}
