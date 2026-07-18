{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glibc,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "catatonit";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "catatonit";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-sc/T4WjCPFfwUWxlBx07mQTmcOApblHygfVT824HcJM=";
  };

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isMusl) [
    glibc
    glibc.static
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    readelf -d $out/bin/catatonit | grep 'There is no dynamic section in this file.'
  '';

  enableParallelBuilding = true;
  passthru.tests = { inherit (nixosTests) podman; };

  meta = {
    description = "Container init that is so simple it's effectively brain-dead";
    homepage = "https://github.com/openSUSE/catatonit";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ erosennin ];
    platforms = lib.platforms.linux;
    mainProgram = "catatonit";
    teams = [ lib.teams.podman ];
  };
})
