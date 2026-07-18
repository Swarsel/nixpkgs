{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nqptp";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "mikebrady";
    repo = "nqptp";
    tag = finalAttrs.version;
    hash = "sha256-f8k1MKNVMqt8Nym1+CWLC5bAKUkmPaBZYTer+EoPAgk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  postInstall = ''
    mkdir -p $out/lib/systemd/system
    cp nqptp.service $out/lib/systemd/system
  '';

  passthru.updateScript = gitUpdater {
    ignoredVersions = ".*(-dev|d0)";
  };

  meta = {
    description = "Daemon and companion application to Shairport Sync that monitors timing data from any PTP clocks";
    homepage = "https://github.com/mikebrady/nqptp";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      jordanisaacs
      adamcstephens
    ];

    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "nqptp";
  };
})
