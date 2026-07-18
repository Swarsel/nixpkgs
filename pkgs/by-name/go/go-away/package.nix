{
  lib,
  # asset compression
  brotli,
  # tinygo currently only supports Go <=1.25
  buildGo125Module,
  # wasm compilation
  clang,
  fetchFromGitea,
  nix-update-script,
  tinygo,
  zopfli,
}:

buildGo125Module (finalAttrs: {
  pname = "go-away";
  version = "0.7.0";

  src = fetchFromGitea {
    owner = "git";
    repo = "go-away";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5rcuR3ke+BSgYJQbJhqQmDgjrtj6jt1Q18eLkRpp8wE=";
    domain = "git.gammaspectra.live";
  };

  postPatch = ''
    patchShebangs *.sh
  '';

  nativeBuildInputs = [
    # build-compress.sh
    brotli
    zopfli

    # build-wasm.sh
    clang
    tinygo
  ];

  vendorHash = "sha256-DOAJrQlh+5gfxKIBbf5rEYt+hZ0luNkX4MxtwNoLiKo=";

  preBuild = ''
    ./build-compress.sh

    # build-wasm.sh
    export HOME=$(mktemp -d)
    go generate -v ./...
  '';

  postInstall = ''
    mkdir -p $out/lib/go-away
    cp -rv examples/snippets $out/lib/go-away/
  '';

  subPackages = [
    "cmd/go-away"
  ];

  passthru.updateScript = nix-update-script {
    # the main repository does not have the releases feed enabled, so use the
    # codeberg mirror
    extraArgs = [
      "--url"
      "https://codeberg.org/gone/go-away"
    ];
  };

  meta = {
    description = "Self-hosted abuse detection and rule enforcement against low-effort mass AI scraping and bots";

    longDescription = ''
      go-away sits in between your site and the Internet / upstream proxy.

      Incoming requests can be selected by rules to be actioned or challenged to filter suspicious requests.

      The tool is designed highly flexible so the operator can minimize impact to legit users, while surgically targeting heavy endpoints or scrapers.

      Challenges can be transparent (not shown to user, depends on backend or other logic), non-JavaScript (challenges common browser properties), or custom JavaScript (from Proof of Work to fingerprinting or Captcha is supported)
    '';

    homepage = "https://git.gammaspectra.live/git/go-away";
    changelog = "https://git.gammaspectra.live/git/go-away/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "go-away";
  };
})
