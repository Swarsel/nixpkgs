{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoreconfHook,
  dotconf,
  espeak,
  fetchpatch,
  flite,
  gettext,
  glib,
  itstool,
  libao,
  libpulseaudio,
  libsndfile,
  libtool,
  mbrola,
  pcaudiolib,
  picotts,
  pkg-config,
  python3Packages,
  replaceVars,
  sonic,
  systemdMinimal,
  texinfo,
  util-linux,
  libsOnly ? false,
  withAlsa ? false,
  withEspeak ? true,
  withFlite ? true,
  withLibao ? true,
  withOss ? false,
  withPico ? true,
  withPulse ? false,
}:

let
  inherit (python3Packages) python pyxdg wrapPython;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "speech-dispatcher";
  version = "0.12.1";

  src = fetchurl {
    url = "https://github.com/brailcom/speechd/releases/download/${finalAttrs.version}/speech-dispatcher-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-sUpSONKH0tzOTdQrvWbKZfoijn5oNwgmf3s0A297pLQ=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      # patch context
      bindir = null;
      utillinux = util-linux;
    })
    (fetchpatch {
      hash = "sha256-7R5BH6QmxovvtXoH/T76qu6YMfm1HE+CA0eB0mzwmfY=";
      name = "use-binsh.patch";
      url = "https://github.com/brailcom/speechd/commit/66d5fe65cffd4c0ce9cfb4c6d292866ed8726999.diff?full_index=1";
    })
  ]
  ++ lib.optionals (withEspeak && espeak.mbrolaSupport) [
    # Replace FHS paths.
    (replaceVars ./fix-mbrola-paths.patch {
      inherit mbrola;
    })
  ];

  postPatch = lib.optionalString withPico ''
    substituteInPlace src/modules/pico.c --replace "/usr/share/pico/lang" "${picotts}/share/pico/lang"
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    gettext
    libtool
    itstool
    texinfo
    wrapPython
  ];

  buildInputs = [
    glib
    dotconf
    libsndfile
    libao
    libpulseaudio
    python
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    systemdMinimal # libsystemd
  ]
  ++ lib.optionals withAlsa [
    alsa-lib
  ]
  ++ lib.optionals withEspeak [
    espeak
    sonic
    pcaudiolib
  ]
  ++ lib.optionals withFlite [
    flite
  ]
  ++ lib.optionals withPico [
    picotts
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    # Audio method falls back from left to right.
    "--with-default-audio-method=\"libao,pulse,alsa,oss\""
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-systemduserunitdir=${placeholder "out"}/lib/systemd/user"
  ]
  ++ lib.optionals withPulse [
    "--with-pulse"
  ]
  ++ lib.optionals withAlsa [
    "--with-alsa"
  ]
  ++ lib.optionals withLibao [
    "--with-libao"
  ]
  ++ lib.optionals withOss [
    "--with-oss"
  ]
  ++ lib.optionals withEspeak [
    "--with-espeak-ng"
  ]
  ++ lib.optionals withPico [
    "--with-pico"
  ];

  postInstall =
    if libsOnly then
      ''
        rm -rf $out/{bin,etc,lib/speech-dispatcher,lib/systemd,libexec,share}
      ''
    else
      ''
        wrapPythonPrograms
      '';

  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
  ];

  pythonPath = [
    pyxdg
  ];

  meta = {
    description =
      "Common interface to speech synthesis" + lib.optionalString libsOnly " - client libraries only";

    homepage = "https://devel.freebsoft.org/speechd";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    # TODO: remove checks for `withPico` once PR #375450 is merged
    platforms = if withAlsa || withPico then lib.platforms.linux else lib.platforms.unix;
    mainProgram = "speech-dispatcher";
  };
})
