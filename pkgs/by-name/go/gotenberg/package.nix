{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  chromium,
  exiftool,
  liberation_ttf_v2,
  libreoffice,
  makeBinaryWrapper,
  makeFontsConf,
  mktemp,
  nix-update-script,
  nixosTests,
  pdfcpu,
  pdftk,
  qpdf,
  unoconv,
}:
let
  fontsConf = makeFontsConf { fontDirectories = [ liberation_ttf_v2 ]; };
  jre' = libreoffice.unwrapped.jdk;
  libreoffice' = "${libreoffice}/lib/libreoffice/program/soffice.bin";
  inherit (lib) getExe;
in
buildGo126Module (finalAttrs: {
  pname = "gotenberg";
  version = "8.34.0";

  src = fetchFromGitHub {
    owner = "gotenberg";
    repo = "gotenberg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HFRymNfhQOBzXBWZhiujr8sn4m/hpfjcBGg/3/C67DU=";
  };

  outputs = [
    "out"
    "hyphen"
  ];

  postPatch = ''
    find ./pkg -name '*_test.go' -exec sed -i -e 's#/tests#${finalAttrs.src}#g' {} \;
  '';

  nativeBuildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-njyxP+1S1ebaF9xJ1kBL9HrTWMTdEhu8MwUF6FYKHvs=";

  checkInputs = [
    chromium
    libreoffice
    pdftk
    qpdf
    unoconv
    pdfcpu
    mktemp
    jre'
  ];

  # These tests fail with a panic, so disable them.
  checkFlags =
    let
      skippedTests = [
        "TestChromiumBrowser_(screenshot|pdf)"
        "TestNewContext"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    export CHROMIUM_BIN_PATH=${getExe chromium}
    export PDFTK_BIN_PATH=${getExe pdftk}
    export QPDF_BIN_PATH=${getExe qpdf}
    export UNOCONVERTER_BIN_PATH=${getExe unoconv}
    export EXIFTOOL_BIN_PATH=${getExe exiftool}
    export PDFCPU_BIN_PATH=${getExe pdfcpu}
    # LibreOffice needs all of these set to work properly
    export LIBREOFFICE_BIN_PATH=${libreoffice'}
    export FONTCONFIG_FILE=${fontsConf}
    export HOME=$(mktemp -d)
    export JAVA_HOME=${jre'}
  '';

  postInstall = ''
    mkdir $hyphen
    cp -r build/chromium-hyphen-data/*/* $hyphen/
  '';

  preFixup = ''
    wrapProgram $out/bin/gotenberg \
      --set CHROMIUM_HYPHEN_DATA_DIR_PATH "$hyphen" \
      --set EXIFTOOL_BIN_PATH "${getExe exiftool}" \
      --set JAVA_HOME "${jre'}" \
      --set PDFCPU_BIN_PATH "${getExe pdfcpu}" \
      --set PDFTK_BIN_PATH "${getExe pdftk}" \
      --set QPDF_BIN_PATH "${getExe qpdf}" \
      --set UNOCONVERTER_BIN_PATH "${getExe unoconv}"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/gotenberg/gotenberg/v8/cmd.Version=${finalAttrs.version}"
  ];

  passthru.tests = {
    inherit (nixosTests) gotenberg;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Converts numerous document formats into PDF files";
    homepage = "https://gotenberg.dev";
    changelog = "https://github.com/gotenberg/gotenberg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ miniharinn ];
    mainProgram = "gotenberg";
  };
})
