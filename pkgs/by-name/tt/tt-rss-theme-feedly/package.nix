{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tt-rss-theme-feedly";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "levito";
    repo = "tt-rss-feedly-theme";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-3mD1aY7gjdvucRzY7sLmZ1RsHtraAg1RGE/3uDp6/o4=";
  };

  installPhase = ''
    mkdir $out

    cp -ra feedly *.css $out
  '';

  dontBuild = true;

  passthru = {
    tests = { inherit (nixosTests) tt-rss; };
  };

  meta = {
    description = "Feedly theme for Tiny Tiny RSS";
    homepage = "https://github.com/levito/tt-rss-feedly-theme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ das_j ];
    platforms = lib.platforms.all;
  };
})
