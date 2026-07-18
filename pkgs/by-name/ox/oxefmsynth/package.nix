{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  vst2-sdk,
}:
stdenv.mkDerivation rec {
  pname = "oxefmsynth";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "oxesoft";
    repo = "oxefmsynth";
    rev = "v${version}";
    sha256 = "1rk71ls33a38wx8i22plsi7d89cqqxrfxknq5i4f9igsw1ipm4gn";
  };

  buildInputs = [ libx11 ];
  buildFlags = [ "VSTSDK_PATH=${vst2-sdk}" ];
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-narrowing" ];

  installPhase = ''
    mkdir -p $out/lib/lxvst
    install -Dm644 oxevst64.so -t $out/lib/lxvst
  '';

  meta = {
    description = "Open source VST 2.4 instrument plugin";
    homepage = "https://github.com/oxesoft/oxefmsynth";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.hirenashah ];
    platforms = [ "x86_64-linux" ];
  };
}
