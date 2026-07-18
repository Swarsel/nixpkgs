{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fanficfare";
  version = "4.54.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Pypts27ksSx8r+nLo3wup2ltbcayJ91VyF2+JchrE2c=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    brotli
    chardet
    cloudscraper
    html5lib
    html2text
    requests
    requests-file
    urllib3
  ];

  doCheck = false; # no tests exist
  pyproject = true;

  meta = {
    description = "Tool for making eBooks from fanfiction web sites";
    homepage = "https://github.com/JimmXinu/FanFicFare";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ dwarfmaster ];
    platforms = lib.platforms.unix;
    mainProgram = "fanficfare";
  };
})
