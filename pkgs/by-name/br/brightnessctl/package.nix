{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  pkg-config,
  systemd,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brightnessctl";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "Hummer12007";
    repo = "brightnessctl";
    tag = finalAttrs.version;
    sha256 = "0immxc7almmpg80n3bdn834p3nrrz7bspl2syhb04s3lawa5y2lq";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "pkg-config" "$PKG_CONFIG"

    substituteInPlace 90-brightnessctl.rules \
      --replace-fail /bin/ ${coreutils}/bin/
  '';

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ systemd ];

  makeFlags = [
    "PREFIX="
    "DESTDIR=$(out)"
    "ENABLE_SYSTEMD=1"
  ];

  doInstallCheck = true;

  installTargets = [
    "install"
    "install_udev_rules"
  ];

  meta = {
    description = "This program allows you read and control device brightness";
    homepage = "https://github.com/Hummer12007/brightnessctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ megheaiulian ];
    platforms = lib.platforms.linux;
    mainProgram = "brightnessctl";
  };

})
