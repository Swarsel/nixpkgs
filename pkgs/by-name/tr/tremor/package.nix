{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libogg,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "tremor";
  version = "unstable-2018-03-16";

  src = fetchFromGitLab {
    owner = "xiph";
    repo = "tremor";
    rev = "562307a4a7082e24553f3d2c55dab397a17c4b4f";
    sha256 = "0m07gq4zfgigsiz8b518xyb19v7qqp76qmp7lb262825vkqzl3zq";
    domain = "gitlab.xiph.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [ libogg ];

  configureFlags = lib.optional (
    stdenv.cc.bintools.isLLVM && lib.versionAtLeast stdenv.cc.bintools.version "17"
  ) "LDFLAGS=-Wl,--undefined-version";

  preConfigure = ''
    sed -i /XIPH_PATH_OGG/d configure
  '';

  meta = {
    description = "Fixed-point version of the Ogg Vorbis decoder";
    homepage = "https://xiph.org/tremor/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
}
