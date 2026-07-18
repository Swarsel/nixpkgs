{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  coreutils,
  gawk,
  getopt,
  gnugrep,
  gnused,
  makeWrapper,
  syslogSupport ? true,
  util-linux ? null,
}:
assert syslogSupport -> util-linux != null;
stdenv.mkDerivation rec {
  pname = "btrfs-auto-snapshot";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "hunleyd";
    repo = "btrfs-auto-snapshot";
    rev = "v${version}";
    hash = "sha256-QpXD0u593BYONjscXSc7oZGUydygs/Hfk3A7MOpn8jQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 btrfs-auto-snapshot $out/bin/btrfs-auto-snapshot
  '';

  postFixup = ''
    wrapProgram $out/bin/btrfs-auto-snapshot \
      --prefix PATH : "${wrapperPath}"
  '';

  dontBuild = true;

  wrapperPath = lib.makeBinPath (
    [
      coreutils
      getopt
      gnugrep
      gnused
      gawk
      btrfs-progs
    ]
    ++ lib.optional syslogSupport util-linux
  );

  meta = {
    description = "BTRFS Automatic Snapshot Service for Linux";

    longDescription = ''
      btrfs-auto-snapshot is a Bash script designed to bring as much of the
      functionality of the wonderful ZFS snapshot tool zfs-auto-snapshot to
      BTRFS as possible. Designed to run from cron (using
      /etc/cron.{daily,hourly,weekly}) it automatically creates a snapshot of
      the specified BTRFS filesystem (or, optionally, all of them) and then
      automatically purges the oldest snapshots of that type (hourly, daily, et
      al) based on a user-defined retention policy.

      Snapshots are stored in a '.btrfs' directory at the root of the BTRFS
      filesystem being snapped and are read-only by default.
    '';

    homepage = "https://github.com/hunleyd/btrfs-auto-snapshot";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ motiejus ];
    platforms = lib.platforms.linux;
    mainProgram = "btrfs-auto-snapshot";
  };
}
