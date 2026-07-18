{
  lib,
  stdenv,
  fetchFromGitLab,
  libusb1,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libjaylink";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "libjaylink";
    repo = "libjaylink";
    tag = finalAttrs.version;
    hash = "sha256-PghPVgovNo/HhNg7c6EGXrqi6jMrb8p/uLqGDIZ7t+s=";
    domain = "gitlab.zapb.de";
  };

  postPatch = ''
    substituteInPlace contrib/60-libjaylink.rules \
      --replace-fail 'GROUP="plugdev"' 'GROUP="jlink"'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ libusb1 ];

  postInstall = ''
    install -Dm644 ../contrib/60-libjaylink.rules $out/lib/udev/rules.d/60-libjaylink.rules
  '';

  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Shared library written in C to access SEGGER J-Link and compatible devices";
    homepage = "https://gitlab.zapb.de/libjaylink/libjaylink";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ felixsinger ];
    platforms = lib.platforms.unix;
  };
})
