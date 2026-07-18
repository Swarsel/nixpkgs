{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg-livepeer,
  gnutls,
  nix-update-script,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "livepeer";
  version = "0.8.10";

  src = fetchFromGitHub {
    owner = "livepeer";
    repo = "go-livepeer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jz8lgZItPDzAGKJrAFLiEUJ5nyTdw6kGneP6LtmWDYw=";
  };

  postPatch = ''
    rm -rf test/e2e # Require docker
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ffmpeg-livepeer
    gnutls
  ];

  vendorHash = "sha256-Cn7GHNrFjGgzKPjSVGnoRE9Q2gd3Ji/ZrdVGB9v+0A8=";

  env.CGO_LDFLAGS = toString [
    "-lm"
  ];

  __darwinAllowLocalNetworking = true;
  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official Go implementation of the Livepeer protocol";
    homepage = "https://livepeer.org";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bot-wxt1221
    ];

    mainProgram = "livepeer";
  };
})
