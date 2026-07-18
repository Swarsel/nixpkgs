{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openresolv";
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "NetworkConfiguration";
    repo = "openresolv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-blWfUXTBPkAYj5o2/lqAfMV4mOHUW1wpPGiUx93Bfyo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/sbin/resolvconf" --set PATH "${coreutils}/bin"
  '';

  configurePhase = ''
    cat > config.mk <<EOF
    PREFIX=$out
    SYSCONFDIR=/etc
    SBINDIR=$out/sbin
    LIBEXECDIR=$out/libexec/resolvconf
    VARDIR=/run/resolvconf
    MANDIR=$out/share/man
    RESTARTCMD=false
    EOF
  '';

  installFlags = [ "SYSCONFDIR=$(out)/etc" ];

  meta = {
    description = "Program to manage /etc/resolv.conf";
    homepage = "https://roy.marples.name/projects/openresolv";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "resolvconf";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "openresolv_project" finalAttrs.version;
    teams = [ lib.teams.security-review ];
  };
})
