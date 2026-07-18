{
  lib,
  fetchFromGitHub,
  coreutils,
  gzip,
  jq,
  makeWrapper,
  qrencode,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "quill-qr";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "colonelpanic8";
    repo = "quill-qr";
    rev = "v${version}";
    sha256 = "1kdsq6csmxfvs2wy31bc9r92l5pkmzlzkyqrangvrf4pbk3sk0r6";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a quill-qr.sh $out/bin/quill-qr.sh
    patchShebangs $out/bin

    wrapProgram $out/bin/quill-qr.sh --prefix PATH : "${
      lib.makeBinPath [
        qrencode
        coreutils
        jq
        gzip
      ]
    }"
  '';

  dontBuild = true;

  meta = {
    description = "Print QR codes for use with https://p5deo-6aaaa-aaaab-aaaxq-cai.raw.ic0.app";
    homepage = "https://github.com/colonelpanic8/quill-qr";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ imalison ];
    platforms = with lib.platforms; linux;
    mainProgram = "quill-qr.sh";
  };
}
