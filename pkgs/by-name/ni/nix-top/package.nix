{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils-unwrapped, # strings
  coreutils,
  findutils,
  getent, # /etc/passwd
  makeWrapper,
  ncurses, # tput
  ruby,
}:

# No gems used, so mkDerivation is fine.
let
  additionalPath = lib.makeBinPath [
    getent
    ncurses
    binutils-unwrapped
    coreutils
    findutils
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nix-top";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "jerith666";
    repo = "nix-top";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dpH1qfAHt8kDEG1QMFcD67rOhDsWZuaw3WSUZdPx3oQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ruby ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/nix-top
    install -D -m755 ./nix-top $out/bin/nix-top
    wrapProgram $out/bin/nix-top \
      --prefix PATH : "$out/libexec/nix-top:${additionalPath}"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -s /bin/stty $out/libexec/nix-top
  ''
  + ''
    runHook postInstall
  '';

  meta = {
    description = "Tracks what nix is building";
    homepage = "https://github.com/jerith666/nix-top";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jerith666 ];
    platforms = lib.platforms.unix;
    mainProgram = "nix-top";
  };
})
