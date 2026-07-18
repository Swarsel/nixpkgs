{
  lib,
  fetchFromGitHub,
  rebar3Relx,
}:

rebar3Relx rec {
  pname = "erlfmt";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "WhatsApp";
    repo = "erlfmt";
    tag = "v${version}";
    hash = "sha256-0guZxRStVHnUCh9+tmP+/FzgZF+TUgB2oCZu+P4FJBs=";
  };

  releaseType = "escript";

  meta = {
    description = "Automated code formatter for Erlang";
    homepage = "https://github.com/WhatsApp/erlfmt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dlesl ];
    platforms = lib.platforms.unix;
    mainProgram = "erlfmt";
  };
}
