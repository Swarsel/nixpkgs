{
  lib,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  jdk25_headless,
  nixosTests,
  stdenvNoCC,
  systemd,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unifi-controller";
  version = "10.5.54";

  # See https://community.ui.com/releases or https://www.ui.com/download/unifi.
  #
  # When upgrading, make sure we don't need to bump `passthru.jrePackage` below
  # as well.
  src = fetchurl {
    url = "https://dl.ui.com/unifi/${finalAttrs.version}/unifi_sysvinit_all.deb";
    hash = "sha256-Ed6N6lbxPgCaDm7w9m8H/nlw9hBJELnzIKr0s7MoaYU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    systemd
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -ar usr/lib/unifi/{dl,lib,webapps} $out

    runHook postInstall
  '';

  passthru = {
    jrePackage = jdk25_headless;

    tests = {
      inherit (nixosTests) unifi;
    };
  };

  meta = {
    description = "Controller for Ubiquiti UniFi access points";
    homepage = "https://www.ui.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      globin
      patryk27
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
