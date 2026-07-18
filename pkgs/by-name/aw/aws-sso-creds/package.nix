{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  xdg-utils,
}:
buildGoModule (finalAttrs: {
  pname = "aws-sso-creds";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "jaxxstorm";
    repo = "aws-sso-creds";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-HFkPx/ptg/xXW2bbvZLSuuckj/SbuJQQcAbNfiTgTLM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-GiloBizb8ec7PgXbzQEOKjyJP5doFnQ2ALH3Y1+AKZw=";

  postInstall = ''
    wrapProgram $out/bin/aws-sso-creds \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = {
    description = "Get AWS SSO temporary creds from an SSO profile";
    homepage = "https://github.com/jaxxstorm/aws-sso-creds";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lafrenierejm ];
    mainProgram = "aws-sso-creds";
  };
})
