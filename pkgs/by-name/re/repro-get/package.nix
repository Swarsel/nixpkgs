{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cacert,
  installShellFiles,
  repro-get,
  testers,
}:

buildGoModule rec {
  pname = "repro-get";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "reproducible-containers";
    repo = "repro-get";
    rev = "v${version}";
    sha256 = "sha256-qLu9SZuHCkKAOhzrBPEEev1iD5mcIBvrbXspHtifsq4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-clpQLRozXFeUGrItL2pfNft2hUNyuyeCP9oMQxagAWs=";

  # The pkg/version test requires internet access, so disable it here and run it
  # in passthru.pkg-version
  preCheck = ''
    rm -rf pkg/version
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd repro-get \
      --bash <($out/bin/repro-get completion bash) \
      --fish <($out/bin/repro-get completion fish) \
      --zsh <($out/bin/repro-get completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/reproducible-containers/${pname}/pkg/version.Version=v${version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      inherit version;
      command = "HOME=$(mktemp -d) repro-get -v";
      package = repro-get;
    };

    "pkg-version" = repro-get.overrideAttrs (old: {
      outputs = [ "out" ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ cacert ];
      preCheck = "";

      installPhase = ''
        rm -rf $out
        touch $out
      '';

      # see invalidateFetcherByDrvHash
      name = "${repro-get.pname}-${
        builtins.unsafeDiscardStringContext (lib.substring 0 12 (baseNameOf repro-get.drvPath))
      }";

      outputHash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
      outputHashAlgo = "sha256";
      outputHashMode = "flat";
      subPackages = [ "pkg/version" ];
    });
  };

  meta = {
    description = "Reproducible apt/dnf/apk/pacman, with content-addressing";
    homepage = "https://github.com/reproducible-containers/repro-get";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "repro-get";
  };
}
