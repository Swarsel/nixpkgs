{
  stdenv,
  fetchPypi,
  jarHash,
  pname,
  unzip,
  version,
}:

stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = jarHash;
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    unzip ${src}
    install -D ./skein/java/skein.jar $out
  '';

  dontUnpack = true;
}
