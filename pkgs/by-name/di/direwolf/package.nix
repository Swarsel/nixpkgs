{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  espeak,
  fetchpatch,
  gpsd,
  hamlib_4,
  nix-update-script,
  perl,
  portaudio,
  python3,
  udev,
  udevCheckHook,
  versionCheckHook,
  extraScripts ? false,
  gpsdSupport ? false,
  hamlib ? hamlib_4,
  hamlibSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "direwolf";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "wb2osz";
    repo = "direwolf";
    tag = finalAttrs.version;
    hash = "sha256-CCJr3l4RxYZLrdCRwio64EzpDyErlV9JDOXD6TH8p9o=";
  };

  # TODO: It would be great if we could make these configurable
  postPatch = ''
    substituteInPlace conf/CMakeLists.txt \
      --replace-fail /etc/udev/rules.d/ $out/lib/udev/rules.d/ \
      --replace-fail /usr/lib/udev/rules.d/ $out/lib/udev/rules.d/
    substituteInPlace src/symbols.c \
      --replace-fail /usr/share/direwolf/symbols-new.txt $out/share/direwolf/symbols-new.txt \
      --replace-fail /opt/local/share/direwolf/symbols-new.txt $out/share/direwolf/symbols-new.txt
    substituteInPlace src/deviceid.c \
      --replace-fail /usr/share/direwolf/tocalls.yaml $out/share/direwolf/tocalls.yaml \
      --replace-fail /opt/local/share/direwolf/tocalls.yaml $out/share/direwolf/tocalls.yaml
    substituteInPlace cmake/cpack/direwolf.desktop.in \
      --replace-fail 'Terminal=false' 'Terminal=true' \
      --replace-fail 'Exec=@APPLICATION_DESKTOP_EXEC@' 'Exec=direwolf'
  ''
  + lib.optionalString extraScripts ''
    patchShebangs scripts/dwespeak.sh
    substituteInPlace scripts/dwespeak.sh \
      --replace-fail espeak ${lib.getBin espeak}
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    udevCheckHook
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      udev
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ portaudio ]
    ++ lib.optionals gpsdSupport [ gpsd ]
    ++ lib.optionals hamlibSupport [ hamlib ]
    ++ lib.optionals extraScripts [
      python3
      perl
      espeak
    ];

  preConfigure = lib.optionals (!extraScripts) ''
    echo "" > scripts/CMakeLists.txt
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = [ "-u" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Soundcard Packet TNC, APRS Digipeater, IGate, APRStt gateway";
    homepage = "https://github.com/wb2osz/direwolf/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      lasandell
      sarcasticadmin
      pandapip1
    ];

    platforms = lib.platforms.unix;
    mainProgram = "direwolf";
  };
})
