{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libusb1,
  sfml_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutecapture";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Gotos";
    repo = "cutecapture";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V8BlZykh9zOTcEypu96Ft9/6CtjsybtD8lBsg9sF5sQ=";
  };

  postPatch = ''
    cat > get_version.sh <<EOF
    #!${stdenv.shell}
    echo ${lib.escapeShellArg finalAttrs.version}
    EOF
  '';

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libusb1
    sfml_2
  ];

  postInstall = ''
    install -Dm644 -t $out/lib/udev/rules.d 95-{3,}dscapture.rules
    install -Dm444 -t $out/share/applications Cute{3,}DSCapture.desktop
    install -Dm444 -t $out/share/icons/hicolor/128x128/apps Cute{3,}DSCapture.png
  '';

  doInstallCheck = true;

  meta = {
    description = "Nintendo DS and 3DS capture software for Linux and Mac";
    homepage = "https://github.com/Gotos/CuteCapture";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ raphaelr ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
