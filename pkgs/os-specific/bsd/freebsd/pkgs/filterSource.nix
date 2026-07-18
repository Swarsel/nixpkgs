{
  lib,
  pkgsBuildBuild,
  runCommand,
  source,
  writeText,
}:

{
  path,
  pname,
  extraPaths ? [ ],
}:

let
  sortedPaths = lib.naturalSort ([ path ] ++ extraPaths);
  filterText = writeText "${pname}-src-include" (
    lib.concatMapStringsSep "\n" (path: "/${path}") sortedPaths
  );
in
runCommand "${pname}-filtered-src"
  {
    nativeBuildInputs = [
      (
        (pkgsBuildBuild.rsync.override {
          enableLZ4 = false;
          enableOpenSSL = false;
          enableXXHash = false;
          enableZstd = false;
        }).overrideAttrs
        {
          doCheck = false;
        }
      )
    ];
  }
  ''
    rsync -a -r --files-from=${filterText} ${source}/ $out
  ''
