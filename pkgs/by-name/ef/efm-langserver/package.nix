{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "efm-langserver";
  version = "0.0.57";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "efm-langserver";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-LWpm5DyHhrSAGxfwEAM0HABPwfsvWEHZ22U93wdldTw=";
  };

  vendorHash = "sha256-3Rz/9p1moT3rQPY3/lka9HZ16T00+bAWCc950IBTkFE=";
  subPackages = [ "." ];

  meta = {
    description = "General purpose Language Server";
    homepage = "https://github.com/mattn/efm-langserver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Philipp-M ];
    mainProgram = "efm-langserver";
  };
})
