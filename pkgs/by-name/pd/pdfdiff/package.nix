{
  lib,
  fetchFromGitHub,
  python3Packages,
  xpdf,
}:

python3Packages.buildPythonApplication rec {
  pname = "pdfdiff";
  version = "0.93";

  src = fetchFromGitHub {
    owner = "cascremers";
    repo = "pdfdiff";
    rev = version;
    hash = "sha256-NPki/PFm0b71Ksak1mimR4w6J2a0jBCbQDTMQR4uZFI=";
  };

  postPatch = ''
    substituteInPlace pdfdiff.py \
      --replace 'pdftotextProgram = "pdftotext"' 'pdftotextProgram = "${xpdf}/bin/pdftotext"' \
      --replace 'progName = "pdfdiff.py"' 'progName = "pdfdiff"'
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    cp pdfdiff.py $out/bin/pdfdiff
    chmod +x $out/bin/pdfdiff
  '';

  dontBuild = true;
  dontConfigure = true;
  pyproject = false;

  meta = {
    description = "Tool to view the difference between two PDF or PS files";
    homepage = "https://github.com/cascremers/pdfdiff";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
