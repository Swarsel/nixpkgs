{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mtprotoproxy";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "alexbers";
    repo = "mtprotoproxy";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/T3NtjDHnEOc/90mCp7NF9J+Bvd1YOTknkq73MQ9KxU=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython ];

  installPhase = ''
    install -Dm755 mtprotoproxy.py $out/bin/mtprotoproxy
    wrapPythonPrograms
  '';

  pythonPath = with python3Packages; [
    pyaes
    pycrypto
    uvloop
  ];

  meta = {
    description = "Async MTProto proxy for Telegram";
    homepage = "https://github.com/alexbers/mtprotoproxy";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = python3.meta.platforms;
    mainProgram = "mtprotoproxy";
  };
})
