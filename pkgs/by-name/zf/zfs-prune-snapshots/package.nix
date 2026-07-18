{
  lib,
  stdenv,
  fetchFromGitHub,
  go-md2man,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zfs-prune-snapshots";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "bahamas10";
    repo = "zfs-prune-snapshots";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-gCf/ZIeIh84WQNs5wZO1/l3zpnl2sNxsFO7cOa92JUM=";
  };

  nativeBuildInputs = [ go-md2man ];

  installPhase = ''
    install -m 755 -D zfs-prune-snapshots $out/bin/zfs-prune-snapshots
    install -m 644 -D man/zfs-prune-snapshots.1 $out/share/man/man1/zfs-prune-snapshots.1
  '';

  makeTargets = [ "man" ];

  meta = {
    description = "Remove snapshots from one or more zpools that match given criteria";
    homepage = "https://github.com/bahamas10/zfs-prune-snapshots";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "zfs-prune-snapshots";
  };
})
