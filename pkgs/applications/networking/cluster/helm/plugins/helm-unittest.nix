{
  lib,
  fetchFromGitHub,
  buildGoModule,
  kubernetes-helm,
  nix-update-script,
  runCommand,
  wrapHelm,
  writableTmpDirAsHomeHook,
}:

let
  version = "1.1.1";
in
buildGoModule (finalAttrs: {
  inherit version;
  pname = "helm-unittest";

  src = fetchFromGitHub {
    owner = "helm-unittest";
    repo = "helm-unittest";
    tag = "v${version}";
    hash = "sha256-oiTW8F0yo+kN943MI2mR5uEEYbMVxJx4RdEislJ3XSo=";
  };

  postPatch = ''
    # Remove the install and upgrade hooks.
    sed -i '/^platformHooks:[[:space:]]*$/,/^[^[:space:]]/d' plugin.yaml
    # Remove the per-platform commands
    sed -i '/^platformCommand:[[:space:]]*$/,/^[^[:space:]]/d' plugin.yaml
    # Add a simple runtime config
    cat <<'EOF' >> ./plugin.yaml
    platformCommand:
      - command: "''$HELM_PLUGIN_DIR/helm-unittest"
    EOF
  '';

  vendorHash = "sha256-4ckjM520MGYb64LbjYURe7AIScm4aGbj81rGKSSYaAo=";

  installPhase = ''
    runHook preInstall

    install -dm755 "$out/helm-unittest"
    install -m755 -Dt "$out/helm-unittest" "$GOPATH/bin/helm-unittest"
    install -m644 -Dt "$out/helm-unittest" ./plugin.yaml

    runHook postInstall
  '';

  subPackages = [ "cmd/helm-unittest" ];

  passthru = {
    tests.smoke =
      let
        helm = wrapHelm kubernetes-helm {
          plugins = [ finalAttrs.finalPackage ];
        };
      in
      runCommand "helm-unittest-plugin-smoke"
        {
          nativeBuildInputs = [
            helm
            writableTmpDirAsHomeHook
          ];
        }
        ''
          cp -r ${./tests/helm-unittest/smoke} chart
          chmod -R u+w chart
          helm unittest chart
          touch $out
        '';

    updateScript = nix-update-script { };
  };

  meta = {
    description = "BDD styled unit test framework for Kubernetes Helm charts as a Helm plugin";
    homepage = "https://github.com/helm-unittest/helm-unittest";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      booxter
      yurrriq
    ];
  };
})
