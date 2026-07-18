{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  libnotify,
  nixosTests,
  python3,
  sudo,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nohang";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "hakavlad";
    repo = "nohang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gCGjQoSxY/MprrcpdFrJ4VrsNyruqsUSPrHoy+R07Io=";
  };

  postPatch = ''
    patchShebangs src
    substituteInPlace src/nohang \
      --replace-fail 'notify-send' '${lib.getExe libnotify}' \
      --replace-fail 'sudo' '${lib.getExe sudo}' \
      --replace-fail "'env'" "'${lib.getExe' coreutils "env"}'"
  '';

  buildInputs = [ python3 ];
  dontBuild = true;

  installFlags = [
    "DESTDIR=${placeholder "out"}"
    "PREFIX=/"
    "SBINDIR=/sbin"
    "SYSCONFDIR=/etc"
    "SYSTEMDUNITDIR=/lib/systemd/system"
  ];

  installTargets = [ "base" ];

  passthru.tests = {
    inherit (nixosTests) nohang;
  };

  meta = {
    description = "Sophisticated low memory handler for Linux";
    homepage = "https://github.com/hakavlad/nohang";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ Dev380 ];
    platforms = lib.platforms.linux;
    mainProgram = "nohang";
  };
})
