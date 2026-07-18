{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "helm-schema";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "losisin";
    repo = "helm-values-schema-json";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2u3cJaSxfHcP9cNknWMdmWm0OjeQX1N2SdJcDGi69Ls=";
  };

  postPatch = ''
    # Remove the install and upgrade hooks
    sed -i '/^hooks:/,+2 d' plugin.yaml

    substituteInPlace {plugin.yaml,plugin.complete} \
      --replace-fail '$HELM_PLUGIN_DIR' '${placeholder "out"}/${finalAttrs.pname}/bin'
  '';

  vendorHash = "sha256-SWzKgQn9s4Nj54s0N6D+onIbpRwXRvJqWVG8LQ31KQA=";

  postInstall = ''
    install -D plugin.complete -t $out/helm-schema/
    install -m644 plugin.yaml -t $out/helm-schema/
    mv $out/bin/{helm-values-schema-json,schema}
    mv $out/bin $out/helm-schema
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Unit tests try to open web server on port 0
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X 'main.Version=v${finalAttrs.version}'"
  ];

  versionCheckProgram = "${placeholder "out"}/helm-schema/bin/schema";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Helm plugin for generating values.schema.json from multiple values files";

    longDescription = ''
      Helm plugin for generating `values.schema.json` from single or
      multiple values files. Schema can be enriched by reading
      annotations from comments. Works only with Helm3 charts.
    '';

    homepage = "https://github.com/losisin/helm-values-schema-json";
    changelog = "https://github.com/losisin/helm-values-schema-json/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ applejag ];
    mainProgram = "schema";
  };
})
