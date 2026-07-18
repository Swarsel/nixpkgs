{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bzip2,
  ensureNewerSourcesForZipFilesHook,
  freetype,
  hlsdk-portable,
  libogg,
  libopus,
  libvorbis,
  libx11,
  makeWrapper,
  opusfile,
  pkg-config,
  python3,
  wafHook,
  # Options
  buildSdk ? false,
  buildServer ? false,
}:
let
  exe = if buildServer then "xash" else "xash3d";
in
stdenv.mkDerivation {
  pname = "xash3d-fwgs";
  version = "0-unstable-2026-04-03";

  src = fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "255c9bcaed1cf02bc4c22276c8e39d5cdbfc0fb5";
    hash = "sha256-xYlGy/JG0LdQbdJ3zU5Eqbl7kVtabDuS6bfUi8C/Bug=";

    postCheckout = ''
      cd $out/3rdparty
      git submodule update --init --recursive \
        MultiEmulator extras/xash-extras gl-wes-v2 gl4es/gl4es \
        libbacktrace/libbacktrace library_suffix maintui mainui nanogl \
        vgui_support
    '';
  };

  nativeBuildInputs = [
    ensureNewerSourcesForZipFilesHook
    python3
    pkg-config
    wafHook
    makeWrapper
  ];

  buildInputs =
    lib.optionals (!buildServer) [
      freetype
      opusfile
      libopus
      libogg
      libvorbis
      bzip2
      SDL2
    ]
    ++ lib.optionals (!buildServer && stdenv.hostPlatform.isLinux) [
      libx11
    ];

  postInstall = ''
    mkdir -p $out/bin
    mv $out/lib/${exe} $out/bin/${exe}-unwrapped
    makeWrapper $out/bin/${exe}-unwrapped $out/bin/${exe} \
      --set XASH3D_RODIR $out/lib/valve \
      --run "export XASH3D_BASEDIR=\$HOME/.xash3d/" \
      --prefix ${
        if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"
      } : "$out/lib"
  ''
  + lib.optionalString buildSdk "cp -TR ${hlsdk-portable}/valve $out/lib/valve";

  dontAddPrefix = true;

  wafConfigureFlags = [
    "-T release"
  ]
  ++ lib.optionals buildServer [
    "-d"
  ]
  ++ lib.optionals (!buildServer) [
    "--sdl-use-pkgconfig"
  ]
  ++ lib.optionals stdenv.buildPlatform.is64bit [ "-8" ];

  wafInstallFlags = [ "--destdir=${placeholder "out"}/lib" ];

  meta = {
    description = "Xash3D FWGS engine";
    homepage = "https://github.com/FWGS/xash3d-fwgs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ r4v3n6101 ];
    platforms = lib.platforms.all;
    mainProgram = exe;
  };
}
