{
  lib,
  fetchFromGitHub,
  binutils,
  bzip2,
  cabextract,
  cpio,
  gitUpdater,
  gnutar,
  gzip,
  lhasa,
  lzip,
  p7zip,
  python3Packages,
  rpm,
  unrar,
  unshield,
  unzip,
  xz,
  unrarSupport ? false,
  unzipSupport ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dtrx";
  version = "8.7.1";

  src = fetchFromGitHub {
    owner = "dtrx-py";
    repo = "dtrx";
    rev = finalAttrs.version;
    sha256 = "sha256-FNSFEGIK0vDNlvqc8BKDCB/0hoxrITfeh59JcyzX3jY=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  makeWrapperArgs =
    let
      archivers = lib.makeBinPath (
        [
          gnutar
          lhasa
          rpm
          binutils
          cpio
          gzip
          p7zip
          cabextract
          unshield
          bzip2
          xz
          lzip
        ]
        ++ lib.optional unzipSupport unzip
        ++ lib.optional unrarSupport unrar
      );
    in
    [
      ''--prefix PATH : "${archivers}"''
    ];

  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Do The Right Extraction: A tool for taking the hassle out of extracting archives";
    homepage = "https://github.com/dtrx-py/dtrx";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "dtrx";
  };
})
