{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gotrue-supabase,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "auth";
  version = "2.188.1";

  src = fetchFromGitHub {
    owner = "supabase";
    repo = "auth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3FR7fWrSocEOL7T0pzwt5XWC4jmXsQrCUQcBMfJZqBI=";
  };

  vendorHash = "sha256-sUQsUCapnNlVMuCMsgC3Pq2Z4Ooz2XO0dRnF1aqPH2I=";
  # integration tests require network to connect to postgres database
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/supabase/auth/internal/utilities.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "auth version";
    package = gotrue-supabase;
  };

  meta = {
    description = "JWT based API for managing users and issuing JWT tokens";
    homepage = "https://github.com/supabase/auth";
    changelog = "https://github.com/supabase/auth/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "auth";
  };
})
