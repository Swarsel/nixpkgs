{
  lib,
  stdenv,
  include,
  mkDerivation,
}:

mkDerivation {
  buildInputs = [
    include
  ];

  # The build system is importing source files from another directory,
  # then trying to put the objects in lib/libcompiler_rt
  # It does not create subdirectories in the lib/libcompiler_rt directory.
  preBuild = ''
    mkdir cpu_model
  ''
  + lib.optionalString stdenv.hostPlatform.isx86_64 ''
    mkdir i386
  '';

  alwaysKeepStatic = true;

  extraPaths = [
    "contrib/llvm-project/compiler-rt"
  ];

  noLibc = true;
  path = "lib/libcompiler_rt";
}
