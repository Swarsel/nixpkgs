{
  lib,
  stdenv,
  fetchFromGitHub,
  nasm,
  unixtools,
}:

let
  version = "10";
in

stdenv.mkDerivation {
  inherit version;
  pname = "gordonflashtool";

  src = fetchFromGitHub {
    owner = "marmolak";
    repo = "GordonFlashTool";
    rev = "release-${version}";
    hash = "sha256-/zpw7kVdQeR7QcRsP1+qcu8+hlEQTGwOKClJkwVcBPg=";
  };

  nativeBuildInputs = [
    nasm
    unixtools.xxd
  ];

  buildPhase = ''
    runHook preBuild
    # build the gordon binary
    make all-boot-code
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gordon $out/bin/gordon
    runHook postInstall
  '';

  meta = {
    description = "Toolset for Gotek SFR1M44-U100 formatted usb flash drives";
    homepage = "https://github.com/marmolak/GordonFlashTool";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ marmolak ];
    platforms = lib.platforms.all;
    mainProgram = "gordon";
  };
}
