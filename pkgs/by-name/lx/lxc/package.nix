{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  dbus,
  docbook2x,
  libapparmor,
  libcap,
  libseccomp,
  libselinux,
  meson,
  ninja,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxc";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "lxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eB68l7SmVxJViGmVlVtEXVD+cRtr4WqOrA8b9ImQ89g=";
  };

  patches = [
    # fix docbook2man version detection
    ./docbook-hack.patch

    # Fix hardcoded path of lxc-user-nic
    # This is needed to use unprivileged containers
    ./user-nic.diff
  ];

  nativeBuildInputs = [
    docbook2x
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    # some hooks use compgen
    bashInteractive
    dbus
    libapparmor
    libcap
    libseccomp
    libselinux
    openssl
    systemd
  ];

  mesonFlags = [
    "-Dinstall-init-files=true"
    "-Dinstall-state-dirs=false"
    "-Dspecfile=false"
    "-Dtools-multicall=true"
    "-Dtools=false"
    "-Dusernet-config-path=/etc/lxc/lxc-usernet"
    "-Ddistrosysconfdir=${placeholder "out"}/etc/lxc"
    "-Dsystemd-unitdir=${placeholder "out"}/lib/systemd/system"
  ];

  doCheck = true;

  # /run/current-system/sw/share
  postInstall = ''
    substituteInPlace $out/etc/lxc/lxc --replace-fail "$out/etc/lxc" "/etc/lxc"
    substituteInPlace $out/libexec/lxc/lxc-net --replace-fail "$out/etc/lxc" "/etc/lxc"

    substituteInPlace $out/share/lxc/templates/lxc-download --replace-fail "$out/share" "/run/current-system/sw/share"
    substituteInPlace $out/share/lxc/templates/lxc-local --replace-fail "$out/share" "/run/current-system/sw/share"
    substituteInPlace $out/share/lxc/templates/lxc-oci --replace-fail "$out/share" "/run/current-system/sw/share"

    substituteInPlace $out/share/lxc/config/common.conf --replace-fail "$out/share" "/run/current-system/sw/share"
    substituteInPlace $out/share/lxc/config/userns.conf --replace-fail "$out/share" "/run/current-system/sw/share"
    substituteInPlace $out/share/lxc/config/oci.common.conf --replace-fail "$out/share" "/run/current-system/sw/share"
  '';

  enableParallelBuilding = true;

  passthru = {
    tests = {
      incus-lts = nixosTests.incus-lts.container;
      lxc = nixosTests.lxc;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Userspace tools for Linux Containers, a lightweight virtualization system";

    longDescription = ''
      LXC containers are often considered as something in the middle between a chroot and a
      full fledged virtual machine. The goal of LXC is to create an environment as close as
      possible to a standard Linux installation but without the need for a separate kernel.
    '';

    homepage = "https://linuxcontainers.org/lxc/";
    changelog = "https://github.com/lxc/lxc/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxc ];
  };
})
