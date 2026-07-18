{
  lib,
  stdenv,
  fetchFromGitHub,
  freefont_ttf,
  gnuplot,
  installShellFiles,
  makeFontsConf,
  makeWrapper,
  perl,
  perlPackages,
}:

let

  fontsConf = makeFontsConf { fontDirectories = [ freefont_ttf ]; };

in

perlPackages.buildPerlPackage rec {
  pname = "feedgnuplot";
  version = "1.61";

  src = fetchFromGitHub {
    owner = "dkogan";
    repo = "feedgnuplot";
    rev = "v${version}";
    sha256 = "sha256-r5rszxr65lSozkUNaqfBn4I4XjLtvQ6T/BG366JXLRM=";
  };

  outputs = [ "out" ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    gnuplot
    perl
  ]
  ++ (with perlPackages; [
    ListMoreUtils
    IPCRun
    StringShellQuote
  ]);

  # Fontconfig error: Cannot load default config file
  env.FONTCONFIG_FILE = fontsConf;
  # Tests require gnuplot 4.6.4 and are completely skipped with gnuplot 5.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/feedgnuplot \
        --prefix "PATH" ":" "$PATH" \
        --prefix "PERL5LIB" ":" "$PERL5LIB"

    installShellCompletion --bash --name feedgnuplot.bash completions/bash/feedgnuplot
    installShellCompletion --zsh completions/zsh/_feedgnuplot
  '';

  meta = {
    description = "General purpose pipe-oriented plotting tool";
    homepage = "https://github.com/dkogan/feedgnuplot/";

    license = with lib.licenses; [
      artistic1
      gpl1Plus
    ];

    maintainers = with lib.maintainers; [ mnacamura ];
    platforms = lib.platforms.unix;
    mainProgram = "feedgnuplot";
  };
}
