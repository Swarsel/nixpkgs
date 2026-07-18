{
  lib,
  buildEnv,
  kubo-fs-repo-migrations,
  kubo-migrator-unwrapped,
  makeWrapper,
}:

buildEnv {
  inherit (kubo-migrator-unwrapped) version;
  pname = "kubo-migrator";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/fs-repo-migrations" \
      --prefix PATH ':' '${lib.makeBinPath [ kubo-fs-repo-migrations ]}'
  '';

  paths = [ kubo-migrator-unwrapped ];
  pathsToLink = [ "/bin" ];

  meta = kubo-migrator-unwrapped.meta // {
    description = "Run the appropriate migrations for migrating the filesystem repository of Kubo";
  };
}
