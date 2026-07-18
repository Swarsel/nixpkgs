{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  hidapi,
  installShellFiles,
  libusb1,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "icesprog";
  version = "1.1b";

  src = fetchFromGitHub {
    owner = "wuxx";
    repo = "icesugar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LGmT+GEZvo0oxmr2kMfSztutnguPpNt2QJfVyBJo82w=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libusb1
    hidapi
  ];

  installPhase = ''
    runHook preInstall

    installBin icesprog

    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/tools/src";

  meta = {
    description = "iCESugar FPGA flash utility";
    homepage = "https://github.com/wuxx/icesugar";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    mainProgram = "icesprog";
  };
})
