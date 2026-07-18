{
  lib,
  stdenv,
  fetchFromGitHub,
  abi-dumper,
  binutils,
  ctags,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abi-compliance-checker";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "lvc";
    repo = "abi-compliance-checker";
    tag = finalAttrs.version;
    sha256 = "1f1f9j2nf9j83sfl2ljadch99v6ha8rq8xm7ax5akc05hjpyckij";
  };

  buildInputs = [
    binutils
    ctags
    perl
  ];

  propagatedBuildInputs = [ abi-dumper ];
  makeFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Tool for checking backward API/ABI compatibility of a C/C++ library";
    homepage = "https://lvc.github.io/abi-compliance-checker";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.all;
    mainProgram = "abi-compliance-checker";
  };
})
