{
  lib,
  stdenv,
  cmake,
  irony,
  llvm,
  llvmPackages,
}:

stdenv.mkDerivation {
  inherit (irony) src version;
  pname = "irony-server";

  nativeBuildInputs = [
    cmake
    llvm
  ];

  buildInputs = [ llvmPackages.libclang ];
  cmakeDir = "server";
  dontUseCmakeBuildDir = true;

  meta = {
    description = "Server part of irony";
    homepage = "https://melpa.org/#/irony";
    license = lib.licenses.free;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "irony-server";
  };
}
