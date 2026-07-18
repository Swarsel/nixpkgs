{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libcap,
  libseccomp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ruri";
  version = "3.9.3";

  src = fetchFromGitHub {
    owner = "RuriOSS";
    repo = "ruri";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cFHbsaZwxu2ABAln5hGDSOib11M/1/4OeXz2EKXFlZI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libcap
    libseccomp
  ];

  meta = {
    description = "Self-contained Linux container implementation";
    homepage = "https://wiki.crack.moe/ruri";
    changelog = "https://github.com/RuriOSS/ruri/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dabao1955 ];
    platforms = lib.platforms.linux;
    mainProgram = "ruri";
    downloadPage = "https://github.com/RuriOSS/ruri";
  };
})
