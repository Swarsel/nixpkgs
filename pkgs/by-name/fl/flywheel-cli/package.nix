{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  os =
    {
      x86_64-linux = "linux";
    }
    .${system} or throwSystem;

  sha256 =
    {
      x86_64-linux = "sha256-SxBjRd95hoh2zwX6IDnkZnTWVduQafPHvnWw8qTuM78=";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flywheel-cli";
  version = "16.2.0";

  src = fetchurl {
    inherit sha256;
    url = "https://storage.googleapis.com/flywheel-dist/cli/${finalAttrs.version}/fw-${os}_amd64-${finalAttrs.version}.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin ./${os}_amd64/fw
    runHook postInstall
  '';

  unpackPhase = ''
    unzip ${finalAttrs.src}
  '';

  meta = {
    description = "Library and command line interface for interacting with a Flywheel site";
    homepage = "https://gitlab.com/flywheel-io/public/python-cli";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ rbreslow ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "fw";
  };
})
