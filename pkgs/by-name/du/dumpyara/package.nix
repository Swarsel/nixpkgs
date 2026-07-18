{
  lib,
  fetchFromGitHub,
  _7zz,
  android-tools,
  callPackage,
  cpio,
  dumpyara,
  erofs-utils,
  nix-update-script,
  python3Packages,
  runCommand,
  squashfsTools,
  zip,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dumpyara";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "sebaubuntu-python";
    repo = "dumpyara";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V7SX1XR+De3py6B3Fmqn1IehN0sGPxUKJ0YlGpBPHG4=";
  };

  __structuredAttrs = true;
  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    brotli
    liblp
    lz4
    protobuf5
    py7zr
    sebaubuntu-libs
    zstandard
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      _7zz
      android-tools
      cpio
      erofs-utils
    ])
  ];

  pyproject = true;

  passthru = {
    tests.requiredTools =
      runCommand "check-required-tools"
        {
          nativeBuildInputs = [
            android-tools
            dumpyara
            squashfsTools
            zip
          ];
        }
        ''
          echo foo > bar.txt
          mkbootimg --kernel bar.txt -o boot.img
          mksquashfs bar.txt system.img
          zip system.zip *.img
          dumpyara system.zip
          touch $out
        '';

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Android firmware dumper";
    homepage = "https://github.com/sebaubuntu-python/dumpyara";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "dumpyara";
  };
})
