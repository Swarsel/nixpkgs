{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  lndir,
  regclient,
  testers,
}:

let
  bins = [
    "regbot"
    "regctl"
    "regsync"
  ];
in

buildGoModule (finalAttrs: {
  pname = "regclient";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-tJBnNtuN9BIlGvHekrvziyBu5gFPzbID/09eAoM5VUc=";
  };

  outputs = [ "out" ] ++ bins;

  nativeBuildInputs = [
    installShellFiles
    lndir
  ];

  vendorHash = "sha256-jpXy3ZWj+JoDKU2r7FanKR8nQGIQPAL9GW4g//e5xZs=";
  env.CGO_ENABLED = 0;

  checkFlags =
    let
      skip = [
        # touch network
        "^ExampleNew$"
        "^TestIsLocal/regclient\\.org$"
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        # The Nix sandbox does not have the /etc/nsswitch.conf file (`hosts: files dns`),
        # so Go defaults to a DNS lookup instead of using the /etc/hosts file.
        "^TestIsLocal/localhost\\.$"
      ];
    in
    [
      "-skip=${builtins.concatStringsSep "|" skip}"
    ];

  postInstall = lib.concatMapStringsSep "\n" (
    bin:
    ''
      export bin=''$${bin}
      export outputBin=bin

      mkdir -p $bin/bin
      mv $out/bin/${bin} $bin/bin
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd ${bin} \
        --bash <($bin/bin/${bin} completion bash) \
        --fish <($bin/bin/${bin} completion fish) \
        --zsh <($bin/bin/${bin} completion zsh)
    ''
    + ''
      lndir -silent $bin $out

      unset bin outputBin
    ''
  ) bins;

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/regclient/regclient/internal/version.vcsTag=${finalAttrs.src.tag}"
  ];

  passthru.tests = lib.mergeAttrsList (
    map (bin: {
      "${bin}Version" = testers.testVersion {
        version = finalAttrs.src.tag;
        command = "${bin} version";
        package = regclient;
      };
    }) bins
  );

  meta = {
    description = "Docker and OCI Registry Client in Go and tooling using those libraries";
    homepage = "https://github.com/regclient/regclient";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.maxbrunet ];
  };
})
