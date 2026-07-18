{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "shc";
  version = "4.0.3";

  src = fetchFromGitHub {
    inherit rev;
    owner = "neurobin";
    repo = "shc";
    sha256 = "0bfn404plsssa14q89k9l3s5lxq3df0sny5lis4j2w75qrkqx694";
  };

  rev = version;

  meta = {
    description = "Shell Script Compiler";
    homepage = "https://neurobin.org/projects/softwares/unix/shc/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    mainProgram = "shc";
  };
}
