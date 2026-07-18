{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  ncurses,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "taizen";
  version = "0-unstable-2024-11-16";

  src = fetchFromGitHub {
    owner = "oppiliappan";
    repo = "taizen";
    rev = "e57f10845d32d51e78c5bbadf9c40780a0fa2481";
    hash = "sha256-5XLRANBRtT8LyyS4EhKgZS+Hc3xFg/+N3rZJTVvVrpo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ncurses
    openssl
  ];

  cargoHash = "sha256-kK9na2Pk3Hl4TYYVVUfeBv6DDDkrD7mIv7eVHXkS5QY=";

  meta = {
    description = "Curses-based mediawiki browser";
    homepage = "https://github.com/oppiliappan/taizen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "taizen";
  };
})
