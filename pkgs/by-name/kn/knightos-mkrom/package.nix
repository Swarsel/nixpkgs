{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mkrom";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "mkrom";
    rev = finalAttrs.version;
    sha256 = "sha256-YFrh0tOGiM90uvU9ZWopW1+9buHDQtetuOtPDSYYaXw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    libxslt.bin
  ];

  installFlags = [ "DESTDIR=$(out)" ];

  installTargets = [
    "install"
    "install_man"
  ];

  meta = {
    description = "Packages KnightOS distribution files into a ROM";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "mkrom";
  };
})
