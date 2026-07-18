{
  stdenv,
  jsoncpp,
  libsecret,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "flutter-secure-storage-linux";

  propagatedBuildInputs = [
    libsecret
    jsoncpp
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ln -s '${src}'/* "$out"

    runHook postInstall
  '';
}
