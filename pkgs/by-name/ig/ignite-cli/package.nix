{
  lib,
  fetchFromGitHub,
  buf,
  buildGoModule,
  go,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "ignite-cli";
  version = "28.11.0";

  src = fetchFromGitHub {
    owner = "ignite";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-guhUvTyUy4YXn0+vtTpIehS731B0Htv9jai6yQ6gRP0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-qbHmF+aE/rF0cm4QARVWOUBogBvfdlCUNaCdFRywt1I=";
  # Many tests require access to either executables, state or networking
  doCheck = false;

  # Required for commands like `ignite version`, `ignite network` and others
  postFixup = ''
    wrapProgram $out/bin/ignite --prefix PATH : ${
      lib.makeBinPath [
        go
        buf
      ]
    }
  '';

  # Required for wrapProgram
  allowGoReference = true;

  meta = {
    description = "All-in-one platform to build, launch, and maintain any crypto application on a sovereign and secured blockchain";
    homepage = "https://ignite.com/";
    changelog = "https://github.com/ignite/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kashw2 ];
    mainProgram = "ignite";
  };
})
