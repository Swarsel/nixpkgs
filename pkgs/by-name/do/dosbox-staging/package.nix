{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_net,
  alsa-lib,
  fluidsynth,
  gitUpdater,
  glib,
  gtest,
  iir1,
  libGL,
  libGLU,
  libjack2,
  libmt32emu,
  libogg,
  libpng,
  libpulseaudio,
  libslirp,
  libsndfile,
  makeWrapper,
  meson,
  ninja,
  opusfile,
  pkg-config,
  speexdsp,
  testers,
  zlib-ng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dosbox-staging";
  version = "0.82.2";

  src = fetchFromGitHub {
    owner = "dosbox-staging";
    repo = "dosbox-staging";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u9W6TfHF+BNeoExcx98kCVJu1BNwWnvjBEg84evMnBw=";
  };

  outputs = [
    "out"
    "man"
  ];

  # replace instances of the get-version.sh script that uses git in meson.build with manual values
  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "meson.project_source_root() + '/scripts/get-version.sh'," "'printf'," \
      --replace-fail "'version', check: true," "'${finalAttrs.version}', check: true," \
      --replace-fail "'./scripts/get-version.sh', 'hash'," "'printf', '${
        builtins.substring 0 5 finalAttrs.shortRev
      }',"
  '';

  nativeBuildInputs = [
    gtest
    makeWrapper
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_net
    fluidsynth
    glib
    iir1
    libGL
    libGLU
    libjack2
    libmt32emu
    libogg
    libpng
    libpulseaudio
    libslirp
    libsndfile
    opusfile
    speexdsp
    zlib-ng
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];

  postInstall = ''
    install -Dm644 $src/contrib/linux/org.dosbox-staging.dosbox-staging.desktop $out/share/applications/
  '';

  # Rename binary, add a wrapper, and copy manual to avoid conflict with
  # original dosbox. Doing it this way allows us to work with frontends and
  # launchers that expect the binary to be named dosbox, but get out of the way
  # of vanilla dosbox if the user desires to install that as well.
  postFixup = ''
    mv $out/bin/dosbox $out/bin/dosbox-staging
    makeWrapper $out/bin/dosbox-staging $out/bin/dosbox

    pushd $man/share/man/man1/
    ln -s dosbox.1.gz dosbox-staging.1.gz
    popd
  '';

  shortRev = "f8c24f8";

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "dosbox --version";
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Modernized DOS emulator; DOSBox fork";

    longDescription = ''
      DOSBox Staging is an attempt to revitalize DOSBox's development
      process. It's not a rewrite, but a continuation and improvement on the
      existing DOSBox codebase while leveraging modern development tools and
      practices.
    '';

    homepage = "https://dosbox-staging.github.io/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Zaechus
    ];

    platforms = lib.platforms.unix;
    priority = 101;
  };
})
