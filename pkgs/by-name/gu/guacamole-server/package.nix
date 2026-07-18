{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  autoreconfHook,
  cairo,
  fetchpatch2,
  ffmpeg-headless,
  freerdp,
  libjpeg_turbo,
  libossp_uuid,
  libpng,
  libpulseaudio,
  libssh2,
  libtelnet,
  libvncserver,
  libvorbis,
  libwebp,
  libwebsockets,
  makeBinaryWrapper,
  nixosTests,
  openssl,
  pango,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guacamole-server";
  version = "1.6.0-unstable-2025-06-29";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "guacamole-server";
    rev = "f3f5b9d76649ccc24f551cb166c81078f4b5e236";
    hash = "sha256-OjTwAQzKUuXfwZXLsL9XjrJc/0be38CmAGG+CoCeNwk=";
  };

  postPatch = ''
    patchShebangs ./src/protocols/rdp/**/*.pl
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    autoreconfHook
    makeBinaryWrapper
    perl
    pkg-config
  ];

  buildInputs = [
    cairo
    ffmpeg-headless
    freerdp
    libjpeg_turbo
    libossp_uuid
    libpng
    libpulseaudio
    libssh2
    libtelnet
    libvncserver
    libvorbis
    libwebp
    libwebsockets
    openssl
    pango
  ];

  configureFlags = [
    "--with-freerdp-plugin-dir=${placeholder "out"}/lib"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=format-truncation"
    "-Wno-error=format-overflow"
    "-Wno-error=deprecated-declarations"
  ];

  postInstall = ''
    ln -s ${freerdp}/lib/* $out/lib/
    wrapProgram $out/sbin/guacd --prefix LD_LIBRARY_PATH ":" $out/lib
  '';

  passthru.tests = {
    inherit (nixosTests) guacamole-server;
  };

  meta = {
    description = "Clientless remote desktop gateway";
    homepage = "https://guacamole.apache.org/";
    license = lib.licenses.asl20;
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "guacd";
  };
})
