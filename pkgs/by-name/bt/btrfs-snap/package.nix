{
  lib,
  fetchFromGitHub,
  bash,
  btrfs-progs,
  coreutils,
  gnugrep,
  makeWrapper,
  stdenvNoCC,
  util-linuxMinimal,
}:
stdenvNoCC.mkDerivation rec {
  pname = "btrfs-snap";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "jf647";
    repo = "btrfs-snap";
    tag = version;
    sha256 = "sha256-SDzLjgNRuR9XpmcYCD9T10MLS+//+pWFGDiTAb8NiLQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  installPhase = ''
    mkdir -p $out/bin
    cp btrfs-snap $out/bin/
    wrapProgram $out/bin/btrfs-snap --prefix PATH : ${
      lib.makeBinPath [
        btrfs-progs # btrfs
        coreutils # cut, date, head, ls, mkdir, readlink, stat, tail, touch, test, [
        gnugrep # grep
        util-linuxMinimal # logger, mount
      ]
    }
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Create and maintain the history of snapshots of btrfs filesystems";
    homepage = "https://github.com/jf647/btrfs-snap";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lionello ];
    platforms = lib.platforms.linux;
    mainProgram = "btrfs-snap";
  };
}
