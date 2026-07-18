{
  lib,
  stdenv,
  fetchFromGitLab,
  docutils,
  gitUpdater,
  glib,
  libvirt,
  libvirt-glib,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvirt-dbus";
  version = "1.4.1";

  src = fetchFromGitLab {
    owner = "libvirt";
    repo = "libvirt-dbus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S4QktQmcnTte4XsIcgc5dkA8LjMJaOD2lljS01WT0dk=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace "data/system/meson.build" \
      --replace-fail ": systemd_system_unit_dir" ": '$out/lib/systemd/system'"

    substituteInPlace "data/session/meson.build" \
      --replace-fail ": systemd_user_unit_dir" ": '$out/lib/systemd/user'"

    substituteInPlace "data/system/org.libvirt.conf.in" \
      --replace-fail 'group="libvirt"' 'group="libvirtd"'
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    docutils
    ninja
  ];

  buildInputs = [
    glib
    libvirt
    libvirt-glib
    systemd
  ];

  mesonFlags = [
    (lib.mesonOption "init_script" "systemd")
    (lib.mesonOption "unix_socket_group" "qemu-libvirtd")
    # TODO: uncomment below on next release
    # (lib.mesonOption "sysusersdir" "${placeholder "out"}/lib/sysusers.d")
  ];

  doCheck = false; # needs running D-Bus and libvirt

  passthru = {
    tests = {
      inherit (nixosTests) libvirtd;
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "libvirt D-Bus API binding";
    homepage = "https://libvirt.org/dbus.html";
    changelog = "https://gitlab.com/libvirt/libvirt-dbus/-/blob/v${finalAttrs.version}/NEWS.rst";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ andre4ik3 ];
    platforms = lib.platforms.linux;
  };
})
