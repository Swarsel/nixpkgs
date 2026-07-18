{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
  # Enable `termcap` (`ncurses`) support.
  enableTermcap ? false,
  ncurses ? null,
}:

assert lib.assertMsg (
  enableTermcap -> ncurses != null
) "`ncurses` must be provided when `enableTermcap` is enabled";

stdenv.mkDerivation (finalAttrs: {
  pname = "editline";
  version = "1.17.1-unstable-2025-05-24";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "editline";
    rev = "f735e4d1d566cac3caa4a5e248179d07f0babefd";
    sha256 = "sha256-MUXxSmhpQd8CZdGGC6Ln9eci85E+GBhlNk28VHUvjaU=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  nativeBuildInputs = [ autoreconfHook ];
  propagatedBuildInputs = lib.optional enableTermcap ncurses;

  configureFlags = [
    # Enable SIGSTOP (Ctrl-Z) behavior.
    (lib.enableFeature true "sigstop")
    # Enable ANSI arrow keys.
    (lib.enableFeature true "arrow-keys")
    # Use termcap library to query terminal size.
    (lib.enableFeature enableTermcap "termcap")
  ];

  makeFlags = lib.optionals stdenv.hostPlatform.isPE [
    "LDFLAGS=-no-undefined"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Readline() replacement for UNIX without termcap (ncurses)";
    homepage = "https://troglobit.com/projects/editline/";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ oxalica ];
    platforms = lib.platforms.all;
  };
})
