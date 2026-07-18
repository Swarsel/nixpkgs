{
  lib,
  makeWrapper,
  parallel,
  perlPackages,
  symlinkJoin,
  extraPerlPackages ? with perlPackages; [
    DBI
    DBDPg
    DBDSQLite
    DBDCSV
    TextCSV
  ],
  willCite ? false,
}:

symlinkJoin {
  inherit (parallel)
    pname
    version
    meta
    outputs
    ;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    ${lib.concatMapStringsSep "\n" (
      output: "ln -s --no-target-directory ${parallel.${output}} \$${output}"
    ) (lib.remove "out" parallel.outputs)}

    rm $out/bin/parallel
    makeWrapper ${parallel}/bin/parallel $out/bin/parallel \
      --set PERL5LIB "${perlPackages.makeFullPerlPath extraPerlPackages}" \
      ${lib.optionalString willCite "--add-flags --will-cite"}
  '';

  name = "parallel-full-${parallel.version}";
  paths = [ parallel ];
}
