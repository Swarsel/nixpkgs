{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  fetchpatch,
  libcap,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  polkit,
  systemdLibs,
  unixtools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtkit";
  version = "0.14";

  src = fetchFromGitLab {
    owner = "pipewire";
    repo = "rtkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y952SHbUWIjg1BKqenHABVWm0S5d/sBac1zRp9BpXB8=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    # Let us override the `sysusersdir` path
    (fetchpatch {
      hash = "sha256-Ffdi6dfZmdBpClpJkPNISmEoeUkIufrObz5g7RSPqLw=";
      url = "https://gitlab.freedesktop.org/pipewire/rtkit/-/commit/621fdc3f2c037781dc279760cfbff64974fdbe77.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    unixtools.xxd
  ];

  buildInputs = [
    dbus
    libcap
    polkit
    systemdLibs
  ];

  mesonFlags = [
    (lib.mesonBool "installed_tests" false)
    (lib.mesonOption "dbus_systemservicedir" "${placeholder "out"}/share/dbus-1/system-services")
    (lib.mesonOption "dbus_interfacedir" "${placeholder "out"}/share/dbus-1/interfaces")
    (lib.mesonOption "dbus_rulesdir" "${placeholder "out"}/etc/dbus-1/system.d")
    (lib.mesonOption "polkit_actiondir" "${placeholder "out"}/share/polkit-1/actions")
    (lib.mesonOption "systemd_systemunitdir" "${placeholder "out"}/etc/systemd/system")
    (lib.mesonOption "systemd_sysusersdir" "${placeholder "out"}/lib/sysusers.d")
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Daemon that hands out real-time priority to processes";
    homepage = "https://gitlab.freedesktop.org/pipewire/rtkit";

    license = with lib.licenses; [
      gpl3Plus
      mit
    ];

    maintainers = [ lib.maintainers.Gliczy ];
    platforms = lib.platforms.linux;
    mainProgram = "rtkitctl";
  };
})
