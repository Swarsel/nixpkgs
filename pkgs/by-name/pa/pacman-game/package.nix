{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pacman-game";
  version = "0-unstable-2017-01-30";

  src = fetchFromGitHub {
    owner = "justinjo";
    repo = "pacman";
    rev = "974db44b655270e5a6532c309ffb0eb2d3962e99";
    hash = "sha256-2GwIv8XMbd8WZBaPp4tOblAzku49UilHmv6bG9A1y+4=";
  };

  # The upstream Makefile hardcodes clang++, which is the default compiler on
  # Darwin but not on Linux. Use the stdenv compiler so it builds everywhere.
  postPatch = ''
    substituteInPlace Makefile --replace-fail "clang++" "c++"
  '';

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    installBin pacman

    runHook postInstall
  '';

  __structuredAttrs = true;

  meta = {
    description = "Command line pacman game";
    homepage = "https://github.com/justinjo/Pacman";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "pacman";
  };
})
