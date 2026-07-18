{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  installShellFiles,
  makeWrapper,
  socat,
  sqlite,
  w3m,
  wget,
}:

stdenv.mkDerivation rec {
  pname = "dasht";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "sunaku";
    repo = "dasht";
    rev = "v${version}";
    sha256 = "08wssmifxi7pnvn9gqrvpzpkc2qpkfbzbhxh0dk1gff2y2211qqk";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/* $out/bin/

    installManPage man/man1/*
    installShellCompletion --zsh etc/zsh/completions/*

    for i in $out/bin/*; do
      echo "Wrapping $i"
      wrapProgram $i --prefix PATH : ${deps};
    done;

    runHook postInstall
  '';

  deps = lib.makeBinPath [
    coreutils
    gnused
    gnugrep
    sqlite
    wget
    w3m
    socat
    gawk
    (placeholder "out")
  ];

  meta = {
    description = "Search API docs offline, in terminal or browser";
    homepage = "https://sunaku.github.io/dasht/man";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = lib.platforms.unix; # cannot test other
  };
}
