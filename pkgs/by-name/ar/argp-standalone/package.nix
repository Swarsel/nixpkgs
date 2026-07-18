{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "argp-standalone";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "argp-standalone";
    repo = "argp-standalone";
    tag = finalAttrs.version;
    sha256 = "jWnoWVnUVDQlsC9ru7oB9PdtZuyCCNqGnMqF/f2m0ZY=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  doCheck = true;

  meta = {
    description = "Standalone version of arguments parsing functions from Glibc";
    homepage = "https://github.com/argp-standalone/argp-standalone";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ amar1729 ];
    platforms = lib.platforms.unix;
  };
})
