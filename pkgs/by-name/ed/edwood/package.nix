{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  plan9port,
}:

buildGoModule (finalAttrs: {
  pname = "edwood";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "rjkroege";
    repo = "edwood";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jKDwNq/iMFqVpPq14kZa+T5fES54f4BAujXUwGlbiTE=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-M7fa46BERNRHbCsAiGqt4GHVVTyrW6iIb6gRc4UuZxA=";
  doCheck = false; # Tests has lots of hardcoded mess.

  postInstall = ''
    mkdir -p $out/share
    cp -r build/font $out/share

    wrapProgram $out/bin/edwood \
      --prefix PATH : ${lib.makeBinPath [ "${plan9port}/plan9" ]} \
      --set PLAN9 $out/share # envvar is read by edwood to determine the font path prefix
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Go version of Plan9 Acme Editor";
    homepage = "https://github.com/rjkroege/edwood";

    license = with lib.licenses; [
      mit
      bsd3
    ];

    maintainers = [ ];
    mainProgram = "edwood";
  };
})
