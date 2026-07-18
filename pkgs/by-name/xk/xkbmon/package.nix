{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxcb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xkbmon";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "xkbmon";
    repo = "xkbmon";
    rev = finalAttrs.version;
    sha256 = "sha256-EWW6L6NojzXodDOET01LMcQT8/1JIMpOD++MCiM3j1Y=";
  };

  buildInputs = [
    libx11
    libxcb
  ];

  installPhase = "install -D -t $out/bin xkbmon";

  meta = {
    description = "Command-line keyboard layout monitor for X11";
    homepage = "https://github.com/xkbmon/xkbmon";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "xkbmon";
  };
})
