{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  corosync,
  libqb,
  nspr,
  nss,
  pkg-config,
  systemd,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corosync-qdevice";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "corosync";
    repo = "corosync-qdevice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JJYD1owtTtXW2yTZNhponzd6Sbj6zjfhein20m/7DQw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    corosync
    libqb
    nss
    nspr
    systemd
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-systemd"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installFlags = [
    "sysconfdir=$(out)/etc"
    "localstatedir=$(out)/var"
    "COROSYSCONFDIR=$(out)/etc/corosync"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/corosync-qnetd";
  versionCheckProgramArg = "-v";

  meta = {
    description = "Corosync Cluster Engine Qdevice";
    homepage = "https://github.com/corosync/corosync-qdevice";
    changelog = "https://github.com/corosync/corosync-qdevice/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ x123 ];
    platforms = lib.platforms.linux;
    mainProgram = "corosync-qdevice";
  };
})
