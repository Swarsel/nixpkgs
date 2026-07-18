{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  libkrb5,
  nix-update-script,
  openldap,
  pkg-config,
  polkit,
  samba,
  systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "realmd";
  version = "0.17.1";

  src = fetchFromGitLab {
    owner = "realmd";
    repo = "realmd";
    tag = finalAttrs.version;
    hash = "sha256-lmNlrXOOUSDk/8H/ge0IRA64bnau9nYUIkW6OyVxbBg=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    # Remove unused tap driver/valgrind checks to make tests work
    ./remove-tap-driver.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    libkrb5
    openldap
    polkit
    samba
    systemdLibs
  ];

  configureFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
    "--with-private-dir=${placeholder "out"}/lib/realmd"
    "--with-systemd-unit-dir=${placeholder "out"}/lib/systemd/system"

    # realmd doesn't fails without proper defaults and distro configuration files
    # These settings will be overridden by the NixOS module
    "--with-distro=redhat"

    # Documentation is disabled
    # We need to run gdbus-codegen & xmlto in **offline mode** to make it work
    # See https://github.com/NixOS/nixpkgs/pull/301631
    "--disable-doc"
  ];

  doCheck = true;

  hardeningDisable = [
    # causes redefinition of _FORTIFY_SOURCE
    "fortify3"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "DBus service for configuring Kerberos and other online identities";
    homepage = "https://gitlab.freedesktop.org/realmd/realmd";
    changelog = "https://gitlab.freedesktop.org/realmd/realmd/-/blob/${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.anthonyroussel ];
    platforms = lib.platforms.linux;
    mainProgram = "realm";
  };
})
