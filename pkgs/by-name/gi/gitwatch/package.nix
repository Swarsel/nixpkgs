{
  lib,
  fetchFromGitHub,
  coreutils,
  git,
  gnugrep,
  gnused,
  inotify-tools,
  makeWrapper,
  openssh,
  runCommand,
}:
runCommand "gitwatch"
  rec {
    pname = "gitwatch";
    version = "0.6";

    src = fetchFromGitHub {
      owner = "gitwatch";
      repo = "gitwatch";
      rev = "v${version}";
      hash = "sha256-O8Qk2fGBAT7NGJYd+PIGOaiDQAnexsDm1y+KFHabQEM=";
    };

    nativeBuildInputs = [ makeWrapper ];

    meta = {
      description = "Watch a filesystem and automatically stage changes to a git";

      longDescription = ''
        A bash script to watch a file or folder and commit changes to a git repo.
      '';

      homepage = "https://github.com/gitwatch/gitwatch";
      changelog = "https://github.com/gitwatch/gitwatch/releases/tag/v${version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ shved ];
      mainProgram = "gitwatch";
    };
  }
  ''
    mkdir -p $out/bin
    dest="$out/bin/gitwatch"
    cp "$src/gitwatch.sh" $dest
    chmod +x $dest
    patchShebangs $dest

    wrapProgram $dest \
      --prefix PATH ';' ${
        lib.makeBinPath [
          coreutils
          git
          gnugrep
          gnused
          inotify-tools
          openssh
        ]
      }
  ''
