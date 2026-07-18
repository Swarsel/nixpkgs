{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "meg";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tomnomnom";
    repo = "meg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uhfPNpvuuC9kBYUBCGE6X46TeZ5QxIcnDQ4HRrn2mT4=";
  };

  vendorHash = "sha256-kQsGRmK7Qqz36whd6RI7Gecj40MM0o/fgRv7a+4yGZI=";

  meta = {
    description = "Fetch many paths for many hosts without flooding hosts";
    homepage = "https://github.com/tomnomnom/meg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ averagebit ];
    mainProgram = "meg";
  };
})
