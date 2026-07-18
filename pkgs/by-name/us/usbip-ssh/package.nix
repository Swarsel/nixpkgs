{
  lib,
  stdenv,
  fetchFromGitHub,
  kmod,
  makeWrapper,
  openssh,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "usbip-ssh";
  version = "0-unstable-2024-10-09";

  src = fetchFromGitHub {
    owner = "turistu";
    repo = "usbip-ssh";
    rev = "1b38f2d7854048bf6129ffe992f3c9caa630e377";
    hash = "sha256-3kGGMlIMTXnBVLgsZijc0yLbyaZZSDf7lr46mg0viWw=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    perl
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 usbip-ssh -t $out/bin
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/usbip-ssh --prefix PATH : ${
      lib.makeBinPath [
        perl
        openssh
        kmod
      ]
    }
  '';

  meta = {
    description = "Import usb devices from another linux machine with ssh's connection forwarding mechanism";
    homepage = "https://github.com/turistu/usbip-ssh";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kagehisa ];
    platforms = lib.platforms.linux;
    mainProgram = "usbip-ssh";
  };
})
