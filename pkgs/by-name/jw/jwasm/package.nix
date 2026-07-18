{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jwasm";
  version = "2.20";

  src = fetchFromGitHub {
    owner = "Baron-von-Riedesel";
    repo = "JWasm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZwSXX/vlAlbRFpWtCmSCGoMT5lu8qz870PZPVktHGRo=";
  };

  outputs = [
    "out"
    "doc"
  ];

  preBuild = ''
    cp ${if stdenv.cc.isClang then "CLUnix.mak" else "GccUnix.mak"} Makefile
    substituteInPlace Makefile \
      --replace "/usr/local/bin" "${placeholder "out"}/bin"
  '';

  preInstall = ''
    mkdir -p ${placeholder "out"}/bin
  '';

  postInstall = ''
    install -Dpm644 $src/Html/License.html \
                    $src/Html/Manual.html \
                    $src/Html/Readme.html \
                    -t $doc/share/doc/jwasm/
  '';

  dontConfigure = true;

  meta = {
    description = "MASM-compatible x86 assembler";
    homepage = "https://github.com/Baron-von-Riedesel/JWasm/";
    changelog = "https://github.com/Baron-von-Riedesel/JWasm/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "jwasm";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
# TODO: generalize for Windows builds
