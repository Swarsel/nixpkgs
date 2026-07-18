{
  lib,
  fetchFromGitHub,
  ioquake3,
  libsodium,
  pan-bindings,
}:
ioquake3.overrideAttrs (old: {
  pname = "ioq3-scion";
  version = "unstable-2024-12-14";

  src = fetchFromGitHub {
    owner = "lschulz";
    repo = "ioq3-scion";
    rev = "a21c257b9ad1d897f6c31883511c3f422317aa0a";
    hash = "sha256-CBy3Av/mkFojXr0tAXPRWKwLeQJPebazXQ4wzKEmx0I=";
  };

  buildInputs = old.buildInputs ++ [
    pan-bindings
    libsodium
  ];

  # gcc15
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  meta = {
    description = "ioquake3 with support for path aware networking";
    homepage = "https://github.com/lschulz/ioq3-scion";
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.linux;
  };
})
