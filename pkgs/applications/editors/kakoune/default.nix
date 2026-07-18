{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kakoune-unwrapped";
  version = "2026.05.21";

  src = fetchFromGitHub {
    owner = "mawww";
    repo = "kakoune";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4nhhvq871mgbpKYhAAVkIi2+MaO1jlt3d3lIXNGkh6I=";
  };

  postPatch = ''
    echo "v${finalAttrs.version}" >.version
  '';

  makeFlags = [
    "debug=no"
    "PREFIX=${placeholder "out"}"
  ];

  preBuild = ''
    appendToVar makeFlags "CXX=$CXX"
  '';

  postInstall = ''
    # make share/kak/autoload a directory, so we can use symlinkJoin with plugins
    cd "$out/share/kak"
    autoload_target=$(readlink autoload)
    rm autoload
    mkdir autoload
    ln -s --relative "$autoload_target" autoload
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/kak -ui json -e "kill 0"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Vim inspired text editor";
    homepage = "http://kakoune.org/";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ philiptaron ];
    platforms = lib.platforms.unix;
    mainProgram = "kak";
  };
})
