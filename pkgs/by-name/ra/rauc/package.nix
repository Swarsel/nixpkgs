{
  lib,
  stdenv,
  fetchFromGitHub,
  composefs,
  curl,
  dbus,
  glib,
  json-glib,
  libnl,
  meson,
  ninja,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  systemdLibs,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rauc";
  version = "1.15.2";

  src = fetchFromGitHub {
    owner = "rauc";
    repo = "rauc";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-wWj4tOUFVn+dgt4741YPF0+x85wRb46DM9lGLNon03Q=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    glib
  ];

  buildInputs = [
    composefs
    curl
    dbus
    glib
    json-glib
    openssl
    util-linux
    libnl
    systemdLibs
  ];

  mesonFlags = [
    "--buildtype=release"
    (lib.mesonEnable "composefs" true)
    (lib.mesonOption "systemdunitdir" "${placeholder "out"}/lib/systemd/system")
    (lib.mesonOption "dbusinterfacesdir" "${placeholder "out"}/share/dbus-1/interfaces")
    (lib.mesonOption "dbuspolicydir" "${placeholder "out"}/share/dbus-1/system.d")
    (lib.mesonOption "dbussystemservicedir" "${placeholder "out"}/share/dbus-1/system-services")
    (lib.mesonOption "systemdcatalogdir" "${placeholder "out"}/lib/systemd/catalog")
  ];

  enableParallelBuilding = true;

  passthru = {
    tests.rauc = nixosTests.rauc;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Safe and secure software updates for embedded Linux";
    homepage = "https://rauc.io";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      emantor
      numinit
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "rauc";
  };
})
