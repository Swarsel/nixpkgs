{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:
buildGoModule (finalAttrs: {
  pname = "docopts";
  version = "0.6.4-with-no-mangle-double-dash";

  src = fetchFromGitHub {
    owner = "docopt";
    repo = "docopts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GIBrJ5qexeJ6ul5ek9LJZC4J3cNExsTrnxdzRCfoqn8=";
  };

  patches = [
    # Migrate project to Go modules.
    (fetchpatch {
      hash = "sha256-Tp05B3tmctnSYIQzCxCc/fhcAWWuEz2ifu/CQZt0XPU=";
      url = "https://github.com/docopt/docopts/pull/74/commits/2c516165e72b35516a64c4529dbc938c0aaa9442.patch";
    })
  ];

  vendorHash = "sha256-+pMgaHB69itbQ+BDM7/oaJg3HrT1UN+joJL7BO/2vxE=";

  meta = {
    description = "Shell interpreter for docopt, the command-line interface description language";
    homepage = "https://github.com/docopt/docopts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.confus ];
    platforms = lib.platforms.unix;
  };
})
