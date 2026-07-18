{
  lib,
  fetchFromGitHub,
  fzf,
  makeWrapper,
  mdcat,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lumen";
  version = "2.30.0";

  src = fetchFromGitHub {
    owner = "jnsahaj";
    repo = "lumen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EoxMYlWHmuprjjhvj3GyCxGDIcT/d+JMda9j75pqs+k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-qTFRfy+Wutee5SbaMaqcYjXgr6xZKYYBIuyVA7jAGiY=";
  # use the non-vendored openssl
  env.OPENSSL_NO_VENDOR = 1;

  # tests that require a git repository to run
  checkFlags = [
    "--skip=vcs::git::tests::test_get_merge_base_returns_ancestor"
    "--skip=vcs::git::tests::test_working_copy_parent_ref_returns_head"
  ];

  postFixup = ''
    wrapProgram $out/bin/lumen --prefix PATH : ${
      lib.makeBinPath [
        fzf
        mdcat
      ]
    }
  '';

  __structuredAttrs = true;

  meta = {
    description = "Fast terminal diff viewer and code review TUI";
    homepage = "https://github.com/jnsahaj/lumen";
    changelog = "https://github.com/jnsahaj/lumen/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    mainProgram = "lumen";
  };
})
