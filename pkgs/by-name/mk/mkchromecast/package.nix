{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg,
  flac,
  gst_all_1,
  lame,
  libsForQt5,
  nodejs,
  opus-tools,
  pulseaudio,
  python3Packages,
  sox,
  vorbis-tools,
  yt-dlp,
  enableSonos ? true,
}:
let
  packages = [
    vorbis-tools
    sox
    flac
    lame
    opus-tools
    gst_all_1.gstreamer
    nodejs
    ffmpeg
    yt-dlp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pulseaudio ];

in
python3Packages.buildPythonApplication {
  pname = "mkchromecast-unstable";
  version = "2025-12-21";

  src = fetchFromGitHub {
    owner = "muammar";
    repo = "mkchromecast";
    rev = "9cdc5f3f9060ef4078522366ce896356515d8e52";
    hash = "sha256-UMzOIxgeTpAFQZtYirOYPoVcKgiKdGx2zwVyWmo32w4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'platform.system() == "Darwin"' 'False' \
      --replace 'platform.system() == "Linux"' 'True'
  '';

  nativeBuildInputs = [ libsForQt5.wrapQtAppsHook ];
  buildInputs = lib.optional stdenv.hostPlatform.isLinux libsForQt5.qtwayland;

  propagatedBuildInputs =
    with python3Packages;
    (
      [
        pychromecast
        psutil
        mutagen
        flask
        netifaces
        requests
        pyqt5
      ]
      ++ lib.optionals enableSonos [ soco ]
    );

  # Relies on an old version (0.7.7) of PyChromecast unavailable in Nixpkgs.
  # Is also I/O bound and impure, testing an actual device, so we disable.
  doCheck = false;

  postInstall = ''
    substituteInPlace $out/${python3Packages.python.sitePackages}/mkchromecast/video.py \
      --replace '/usr/share/mkchromecast/nodejs/' '${placeholder "out"}/share/mkchromecast/nodejs/'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install -Dm 755 -t $out/bin bin/audiodevice
    substituteInPlace $out/${python3Packages.python.sitePackages}/mkchromecast/audio_devices.py \
      --replace './bin/audiodevice' '${placeholder "out"}/bin/audiodevice'
  '';

  dontWrapQtApps = true;
  format = "setuptools";

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath packages}"
  ];

  meta = {
    description = "Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices";
    homepage = "https://mkchromecast.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ shou ];
    mainProgram = "mkchromecast";
  };
}
