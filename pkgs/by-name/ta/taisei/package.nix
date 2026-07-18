{
  lib,
  stdenv,
  fetchFromGitHub,
  cglm,
  cmake,
  # Build depends
  docutils,
  freetype,
  gamemode,
  gettext,
  glslang,
  libogg,
  libpng,
  libunibreak,
  libwebp,
  makeBinaryWrapper,
  makeWrapper,
  meson,
  mimalloc,
  ninja,
  openssl,
  opusfile,
  pkg-config,
  python3Packages,
  # Runtime depends
  sdl3,
  shaderc,
  spirv-cross,
  zlib,
  zstd,
  gamemodeSupport ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taisei";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "taisei-project";
    repo = "taisei";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xjEfSrtxZBBWUU8nv0fyNAofHSGVTeO3CBR/BhKSGHg=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    docutils
    meson
    ninja
    pkg-config
    python3Packages.python
    shaderc
    makeWrapper
    makeBinaryWrapper
    cmake
    gettext
  ];

  buildInputs = [
    sdl3
    cglm
    freetype
    libpng
    libwebp
    zlib
    zstd
    opusfile
    openssl
    mimalloc
    libogg
    libunibreak
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    glslang
    spirv-cross
  ]
  ++ lib.optional gamemodeSupport gamemode;

  mesonFlags = [
    (lib.mesonEnable "shader_transpiler_dxbc" false)
    (lib.mesonEnable "package_data" false)
    (lib.mesonBool "b_lto" false)
    (lib.mesonEnable "gamemode" gamemodeSupport)
    (lib.mesonEnable "install_freedesktop" stdenv.hostPlatform.isLinux)
    (lib.mesonEnable "install_macos_bundle" stdenv.hostPlatform.isDarwin)
    (lib.mesonEnable "install_relocatable" stdenv.hostPlatform.isDarwin)
    (lib.mesonEnable "shader_transpiler" stdenv.hostPlatform.isDarwin)
  ];

  # Forced to use builtin-sincos because the symbol isn't available otherwise
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin " -Dsincos=__builtin_sincos";

  preConfigure = ''
    patchShebangs .
  '';

  postInstall =
    lib.optionalString (stdenv.hostPlatform.isLinux && gamemodeSupport) ''
      wrapProgram $out/bin/taisei \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gamemode ]}"
    ''
    +

      lib.optionalString stdenv.hostPlatform.isDarwin ''
        mkdir -p $out/Applications $out/bin

        mv $out/Taisei.app $out/Applications/
        # regular symlink will fail here due to resources being missed
        makeBinaryWrapper $out/Applications/Taisei.app/Contents/MacOS/Taisei $out/bin/taisei
      '';

  meta = {
    description = "Free and open-source Touhou Project clone and fangame";

    longDescription = ''
      Taisei is an open clone of the Tōhō Project series. Tōhō is a one-man
      project of shoot-em-up games set in an isolated world full of Japanese
      folklore.
    '';

    homepage = "https://taisei-project.org/";
    changelog = "https://github.com/taisei-project/taisei/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      mit
      cc-by-40
    ];

    maintainers = with lib.maintainers; [
      lambda-11235
      Gliczy
      philocalyst
    ];

    platforms = lib.platforms.all;
    mainProgram = "taisei";
  };
})
