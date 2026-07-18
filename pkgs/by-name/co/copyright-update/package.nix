{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "copyright-update";
  version = "2025.0404";

  src = fetchFromGitHub {
    owner = "jaalto";
    repo = "project--copyright-update";
    rev = "release/${version}";
    sha256 = "sha256-FeKWCgCDA77iJ/cWtfx6hXSyWxwmlkW4EidPxy1W9VY=";
    name = "${pname}-${version}-src";
  };

  buildInputs = [ perl ];

  installFlags = [
    "INSTALL=install"
    "prefix=$(out)"
  ];

  meta = {
    description = "Updates the copyright information in a set of files";
    homepage = "https://github.com/jaalto/project--copyright-update";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
    mainProgram = "copyright-update";
  };
}
