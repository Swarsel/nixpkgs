{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  check,
  flex,
  libbsd,
  libdaemon,
  nixosTests,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radvd";
  version = "2.21";

  src = fetchFromGitHub {
    owner = "radvd-project";
    repo = "radvd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-02ZoLJ8nCk531M6DkP3UIPXgWyOOl2X163ou0ezHwKE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
    check
  ];

  buildInputs = [
    libdaemon
    libbsd
  ];

  # Needed for cross-compilation
  makeFlags = [ "AR=${stdenv.cc.targetPrefix}ar" ];

  passthru.tests = {
    inherit (nixosTests) connman ipv6 systemd-networkd-ipv6-prefix-delegation;
    privacy_networkd = nixosTests.networking.networkd.privacy;
    privacy_scripted = nixosTests.networking.scripted.privacy;
  };

  meta = {
    description = "IPv6 Router Advertisement Daemon";
    homepage = "http://www.litech.org/radvd/";
    changelog = "https://github.com/radvd-project/radvd/blob/${finalAttrs.src.rev}/CHANGES";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/radvd-project/radvd";
  };
})
