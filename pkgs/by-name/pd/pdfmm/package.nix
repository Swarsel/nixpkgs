{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  ghostscript,
  gnused,
  locale,
  resholve,
  zenity,
}:

resholve.mkDerivation {
  pname = "pdfmm";
  version = "unstable-2019-01-24";

  src = fetchFromGitHub {
    owner = "jpfleury";
    repo = "pdfmm";
    rev = "45ee7796659d23bb030bf06647f1af85e1d2b52d";
    hash = "sha256-TOISD/2g7MwnLrtpMnfr2Ln0IiwlJVNavWl4eh/uwN0=";
  };

  installPhase = ''
    install -Dm 0755 pdfmm $out/bin/pdfmm
  '';

  dontBuild = true;

  solutions.default = {
    execer = [
      "cannot:${zenity}/bin/zenity"
    ];

    fake = {
      # only need xmessage if zenity is unavailable
      external = [ "xmessage" ];
    };

    inputs = [
      coreutils
      ghostscript
      locale
      zenity
      gnused
    ];

    interpreter = "${bash}/bin/bash";
    keep."$toutLu" = true;

    scripts = [
      "bin/pdfmm"
    ];
  };

  meta = {
    description = "Graphical assistant to reduce the size of a PDF file";
    homepage = "https://github.com/jpfleury/pdfmm";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "pdfmm";
  };
}
