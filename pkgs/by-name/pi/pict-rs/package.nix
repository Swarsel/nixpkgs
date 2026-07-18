{
  lib,
  stdenv,
  exiftool,
  fetchFromGitea,
  ffmpeg,
  imagemagick,
  makeWrapper,
  nixosTests,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pict-rs";
  version = "0.5.24";

  src = fetchFromGitea {
    owner = "asonix";
    repo = "pict-rs";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-jKUDrYBGaWyumnlzMyj+oC41rx8kVnkkUxixSCwFp3Y=";
    domain = "git.asonix.dog";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-W4Bj+juON8mPyXDHgFpTBBFOvQlmYIKihXHBHwelah4=";

  env = {
    # needed for internal protobuf c wrapper library
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
  };

  postInstall = ''
    wrapProgram "$out/bin/pict-rs" \
        --prefix PATH : "${
          lib.makeBinPath [
            imagemagick
            ffmpeg
            exiftool
          ]
        }"
  '';

  passthru.tests = { inherit (nixosTests) pict-rs; };

  meta = {
    description = "Simple image hosting service";
    homepage = "https://git.asonix.dog/asonix/pict-rs";
    license = with lib.licenses; [ agpl3Plus ];
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "pict-rs";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
