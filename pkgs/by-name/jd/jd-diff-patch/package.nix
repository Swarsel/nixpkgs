{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "jd-diff-patch";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "josephburnett";
    repo = "jd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WH6fweuntzIjoc7HodflPxEPsrJ/9t77d0z22CHjBVA=";
  };

  vendorHash = "sha256-qo5yG7DqScC4/bU7vWEKLqTZ/j+QMTg2vpl3WHjxLUI=";

  # not including web ui
  excludedPackages = [
    "gae"
    "pack"
  ];

  sourceRoot = "${finalAttrs.src.name}/v2";

  meta = {
    description = "Commandline utility and Go library for diffing and patching JSON values";
    homepage = "https://github.com/josephburnett/jd";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      juliusfreudenberger
    ];

    mainProgram = "jd";
  };
})
