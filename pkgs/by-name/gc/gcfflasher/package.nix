{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libgpiod,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gcfflasher";
  version = "4.12.1";

  src = fetchFromGitHub {
    owner = "dresden-elektronik";
    repo = "gcfflasher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L0BelCcwYmPDfWPCjXQQ0Lmk/C1BHuQKk3dLRfo2OMc=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libgpiod
  ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 GCFFlasher $out/bin/GCFFlasher
    runHook postInstall
  '';

  meta = {
    description = "CFFlasher is the tool to program the firmware of dresden elektronik's Zigbee products";
    homepage = "https://github.com/dresden-elektronik/gcfflasher";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fleaz ];
    platforms = lib.platforms.all;
    mainProgram = "GCFFlasher";
  };
})
