{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildGoModule,
  compressDrvWeb,
  coreutils,
  fetchPnpmDeps,
  git,
  gitea,
  gzip,
  makeWrapper,
  nixosTests,
  nodejs,
  openssh,
  pnpmConfigHook,
  pnpm_10,
  sqliteSupport ? true,
}:

let
  pnpm = pnpm_10;

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit (gitea) src version;
    pname = "gitea-frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      make frontend
    '';

    installPhase = ''
      mkdir -p $out
      cp -R public $out/
    '';

    __darwinAllowLocalNetworking = true;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-FroVRhNzCLtbW9Z0s6xr4l0mIX+hY4KOomZAhPILWlY=";
    };
  });
in
buildGoModule (finalAttrs: {
  pname = "gitea";
  version = "1.26.4";

  src = fetchFromGitHub {
    owner = "go-gitea";
    repo = "gitea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xfLhiQMygYKgSMrvmH2V/LIMeaA4ovOeUDT4RUwhvgo=";
  };

  outputs = [
    "out"
    "data"
  ];

  patches = [ ./static-root-path.patch ];

  postPatch = ''
    substituteInPlace modules/setting/server.go --subst-var data
    substituteInPlace go.mod \
      --replace-fail "go 1.26.3" "go 1.26"
  '';

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-VyzfBZnxnubNIdf+xwLav4W4DgapcLLKN1aKrZ9NbDg=";

  postInstall = ''
    mkdir $data
    ln -s ${frontend}/public $data/public
    cp -R ./{templates,options} $data
    mkdir -p $out
    cp -R ./options/locale $out/locale

    wrapProgram $out/bin/gitea \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          git
          gzip
          openssh
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X 'main.Tags=${lib.concatStringsSep " " finalAttrs.tags}'"
  ];

  # go-modules derivation doesn't provide $data
  # so we need to wait until it is built, and then
  # at that time we can then apply the substituteInPlace
  overrideModAttrs = _: {
    postPatch = ''
      substituteInPlace go.mod \
        --replace-fail "go 1.26.3" "go 1.26"
    '';
  };

  proxyVendor = true;
  subPackages = [ "." ];

  tags = lib.optionals sqliteSupport [
    "sqlite"
    "sqlite_unlock_notify"
  ];

  passthru = {
    data-compressed =
      lib.warn "gitea.passthru.data-compressed is deprecated. Use \"compressDrvWeb gitea.data\"."
        (compressDrvWeb gitea.data { });

    tests = nixosTests.gitea;
  };

  meta = {
    description = "Git with a cup of tea";
    homepage = "https://about.gitea.com";
    changelog = "https://github.com/go-gitea/gitea/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      techknowlogick
      SuperSandro2000
    ];

    mainProgram = "gitea";
  };
})
