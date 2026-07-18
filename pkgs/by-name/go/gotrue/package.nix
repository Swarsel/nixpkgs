{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gotrue";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "netlify";
    repo = "gotrue";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9h6CyCY7741tJR+qWDLwgPkAtE/kmaoTqlXEY+mOW58=";
  };

  vendorHash = "sha256-x96+l9EBzYplGRFHsfQazSjqZs35bdXQEJv3pBuaJVo=";
  # integration tests require network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/netlify/gotrue/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "SWT based API for managing users and issuing SWT tokens";
    homepage = "https://github.com/netlify/gotrue";
    changelog = "https://github.com/netlify/gotrue/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gotrue";
  };
})
