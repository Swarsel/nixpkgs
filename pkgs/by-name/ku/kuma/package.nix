{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  coredns,
  installShellFiles,
  components ? lib.optionals isFull [
    "kumactl"
    "kuma-cp"
    "kuma-dp"
  ],
  enableGateway ? false,
  isFull ? true,
  pname ? "kuma",
}:

buildGoModule rec {
  inherit pname;
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "kumahq";
    repo = "kuma";
    tag = version;
    hash = "sha256-C/q3fCcMMnqjXeoO/t/YOKHLq8HDNfF+x75nCcjwwvE=";
  };

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals isFull [ coredns ];
  vendorHash = "sha256-KgZYKopW+FOdwBIGxa2RLiEbefZ/1vAhcsWtcYhgdFs=";

  preBuild = ''
    export HOME=$TMPDIR
  '';

  # no test files
  doCheck = false;

  postInstall =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) (
      lib.concatMapStringsSep "\n" (p: ''
        installShellCompletion --cmd ${p} \
          --bash <($out/bin/${p} completion bash) \
          --fish <($out/bin/${p} completion fish) \
          --zsh <($out/bin/${p} completion zsh)
      '') components
    )
    + lib.optionalString isFull ''
      ln -sLf ${coredns}/bin/coredns $out/bin
    '';

  ldflags =
    let
      prefix = "github.com/kumahq/kuma/pkg/version";
    in
    [
      "-s"
      "-w"
      "-X ${prefix}.version=${version}"
      "-X ${prefix}.gitTag=${version}"
      "-X ${prefix}.gitCommit=${version}"
      "-X ${prefix}.buildDate=${version}"
    ];

  subPackages = map (p: "app/" + p) components;
  tags = lib.optionals enableGateway [ "gateway" ];

  meta = {
    description = "Service mesh controller";
    homepage = "https://kuma.io/";
    changelog = "https://github.com/kumahq/kuma/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
  };
}
