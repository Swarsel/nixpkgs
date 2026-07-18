{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  caddy,
  file,
  lessc,
  linkchecker,
  multimarkdown,
  perlPackages,
  python3Packages,
  sass,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "styx";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "styx-static";
    repo = "styx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-f6iA/nHpKnm3BALoQq8SzdcSzJLCFSferEf69SpgD2Y=";
  };

  outputs = [
    "out"
    "lib"
    "themes"
  ];

  nativeBuildInputs = [ asciidoctor ];

  propagatedBuildInputs = [
    file
    lessc
    sass
    asciidoctor
    multimarkdown
    perlPackages.ImageExifTool
    python3Packages.parsimonious
  ];

  installPhase = ''
    mkdir $out
    install -D -m 777 src/styx.sh $out/bin/styx

    mkdir -p $out/share/styx-src
    cp -r ./* $out/share/styx-src

    mkdir -p $out/share/doc/styx
    asciidoctor src/doc/index.adoc       -o $out/share/doc/styx/index.html
    asciidoctor src/doc/styx-themes.adoc -o $out/share/doc/styx/styx-themes.html
    asciidoctor src/doc/library.adoc     -o $out/share/doc/styx/library.html
    cp -r src/doc/highlight $out/share/doc/styx/
    cp -r src/doc/imgs $out/share/doc/styx/

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/doc/styx/index.html
    substituteAllInPlace $out/share/doc/styx/styx-themes.html
    substituteAllInPlace $out/share/doc/styx/library.html

    mkdir -p $out/share/styx/scaffold
    cp -r src/scaffold $out/share/styx
    cp -r src/tools $out/share/styx

    mkdir $lib
    cp -r src/lib/* $lib

    mkdir $themes
    cp -r themes/* $themes
  '';

  linkcheck = "${linkchecker}/bin/linkchecker";
  server = "${caddy}/bin/caddy";

  meta = {
    description = "Nix based static site generator";
    homepage = "https://styx-static.github.io/styx-site/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "styx";
    downloadPage = "https://github.com/styx-static/styx/";
  };
})
