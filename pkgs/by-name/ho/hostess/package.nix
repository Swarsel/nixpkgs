{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hostess";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "cbednarski";
    repo = "hostess";
    rev = "v${finalAttrs.version}";
    sha256 = "1izszf60nsa6pyxx3kd8qdrz3h47ylm17r9hzh9wk37f61pmm42j";
  };

  vendorHash = null;
  subPackages = [ "." ];

  meta = {
    description = "Idempotent command-line utility for managing your /etc/hosts* file";
    homepage = "https://github.com/cbednarski/hostess";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ edlimerkaj ];
    mainProgram = "hostess";
  };
})
