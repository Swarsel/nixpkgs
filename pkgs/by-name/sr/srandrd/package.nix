{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxinerama,
  libxrandr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srandrd";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "jceb";
    repo = "srandrd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Wf+tVqDaNAiH6UHN8fFv2wM+LEch6wKlZOkqWEqLLkw=";
  };

  buildInputs = [
    libx11
    libxrandr
    libxinerama
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple randr daemon";
    homepage = "https://github.com/jceb/srandrd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.utdemir ];
    platforms = lib.platforms.linux;
    mainProgram = "srandrd";
  };

})
