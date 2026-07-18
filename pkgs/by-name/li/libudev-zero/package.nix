{
  lib,
  stdenv,
  fetchFromGitHub,
  hwdata,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-zero";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "illiliti";
    repo = "libudev-zero";
    rev = finalAttrs.version;
    sha256 = "sha256-uKOfN9oJBFkR5n92bQ8RxVxfNaE2EKajrQseDkH5q+k=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "AR=${stdenv.cc.targetPrefix}ar"
    "USB_IDS_PATH=${hwdata}/share/hwdata/usb.ids"
  ];

  # Just let the installPhase build stuff, because there's no
  # non-install target that builds everything anyway.
  dontBuild = true;
  installTargets = lib.optionals stdenv.hostPlatform.isStatic "install-static";

  passthru.tests = {
    pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Daemonless replacement for libudev";
    homepage = "https://github.com/illiliti/libudev-zero";
    changelog = "https://github.com/illiliti/libudev-zero/releases/tag/${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      qyliss
    ];

    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libudev" ];
  };
})
