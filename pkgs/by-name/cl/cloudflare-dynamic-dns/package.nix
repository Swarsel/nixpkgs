{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cloudflare-dynamic-dns,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "cloudflare-dynamic-dns";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "zebradil";
    repo = "cloudflare-dynamic-dns";
    tag = finalAttrs.version;
    hash = "sha256-EMT4vFm1EJxHFfnjh4ExfWOqaA+s9bJbI71wj//oRv0=";
  };

  vendorHash = "sha256-1x1Hw343ylhGsbNcj4hwweYnACoVZSdycwBbGUVuu+k=";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=nixpkg-${finalAttrs.version}"
    "-X=main.date=1970-01-01"
  ];

  subPackages = ".";
  passthru.tests.version = testers.testVersion { package = cloudflare-dynamic-dns; };

  meta = {
    description = "Dynamic DNS client for Cloudflare";
    homepage = "https://github.com/Zebradil/cloudflare-dynamic-dns";
    changelog = "https://github.com/Zebradil/cloudflare-dynamic-dns/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.zebradil ];
    mainProgram = "cloudflare-dynamic-dns";
  };
})
