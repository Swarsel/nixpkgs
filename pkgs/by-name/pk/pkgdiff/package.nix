{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perl,
  wdiff,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pkgdiff";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "lvc";
    repo = "pkgdiff";
    rev = finalAttrs.version;
    sha256 = "sha256-/xhORi/ZHC4B2z6UYPOvDzfgov1DcozRjX0K1WYrqXM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];
  makeFlags = [ "prefix=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/pkgdiff --prefix PATH : ${lib.makeBinPath [ wdiff ]}
  '';

  dontBuild = true;

  meta = {
    description = "Tool for visualizing changes in Linux software packages";
    homepage = "https://lvc.github.io/pkgdiff/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pkgdiff";
  };
})
