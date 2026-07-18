{
  lib,
  fetchFromGitHub,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "riff";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "riff";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ThHkEvu+lWojHmEgcrwdZDPROfxznB7vv78msyZf90A=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-JghCYYDf2keV9UFU5m+qDIIb7+V0aPwVzR41J01pXcI=";

  postInstall = ''
    wrapProgram $out/bin/riff --set-default RIFF_DISABLE_TELEMETRY true
  '';

  meta = {
    description = "Tool that automatically provides external dependencies for software projects";
    homepage = "https://riff.sh";
    changelog = "https://github.com/DeterminateSystems/riff/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "riff";
  };
})
