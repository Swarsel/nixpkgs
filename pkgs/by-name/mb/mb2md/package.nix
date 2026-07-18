{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  perlPackages,
}:

let
  perlDeps = with perlPackages; [ TimeDate ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mb2md";
  version = "3.20";

  src = fetchurl {
    url = "http://batleth.sapienti-sat.org/projects/mb2md/mb2md-${finalAttrs.version}.pl.gz";
    sha256 = "0bvkky3c90738h3skd2f1b2yy5xzhl25cbh9w2dy97rs86ssjidg";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perlPackages.perl ];

  installPhase = ''
    install -D $sourceRoot/mb2md.pl $out/bin/mb2md
  '';

  postFixup = ''
    wrapProgram $out/bin/mb2md \
      --set PERL5LIB "${perlPackages.makePerlPath perlDeps}"
  '';

  unpackPhase = ''
    sourceRoot=.
    gzip -d < $src > mb2md.pl
  '';

  meta = {
    description = "mbox to maildir tool";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.jb55 ];
    platforms = lib.platforms.all;
    mainProgram = "mb2md";
  };
})
