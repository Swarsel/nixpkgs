{
  lib,
  stdenv,
  fetchFromGitLab,
  eigen,
  hidapi,
  libopus,
  libpulseaudio,
  portaudio,
  qt6,
  qt6Packages,
  rtaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wfview";
  version = "2.23";

  src = fetchFromGitLab {
    owner = "eliggett";
    repo = "wfview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RQjNdeBvONxqUdybUvO17lTFjM4kkGx10fNdHsvH+0M=";
  };

  patches = [
    # Remove syscalls during build to make it reproducible
    # We also need to adjust some header paths for darwin
    ./remove-hard-encodings.patch
  ];

  nativeBuildInputs = with qt6; [
    wrapQtAppsHook
    qmake
  ];

  buildInputs = [
    eigen
    hidapi
    libopus
    portaudio
    rtaudio
    qt6.qtbase
    qt6.qtserialport
    qt6.qtmultimedia
    qt6.qtwebsockets
    qt6Packages.qcustomplot
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libpulseaudio
  ];

  env.LANG = "C.UTF-8";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -pv $out/Applications
    mv -v "$out/bin/wfview.app" $out/Applications

    # wrap executable to $out/bin
    makeWrapper "$out/Applications/wfview.app/Contents/MacOS/wfview" "$out/bin/wfview"
  '';

  qmakeFlags = [ "wfview.pro" ];

  meta = {
    description = "Open-source software for the control of modern Icom radios";
    homepage = "https://wfview.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.unix;
    mainProgram = "wfview";
  };
})
