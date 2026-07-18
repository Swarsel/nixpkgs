{
  buildNpmPackage,
  llama-swap,
}:

buildNpmPackage (finalAttrs: {
  inherit (llama-swap) version src;
  pname = "${llama-swap.pname}-ui";

  postPatch = ''
    substituteInPlace vite.config.ts \
      --replace-fail "../internal/server/ui_dist" "${placeholder "out"}/ui_dist"
  '';

  npmDepsHash = "sha256-NJqEJ+XTdpPFtJJxP4CGu+JDUW7lKDcFgsixQJ3SXtQ=";

  # bundled "ui_dist" doesn't need node_modules
  postInstall = ''
    rm -rf $out/lib
  '';

  sourceRoot = "${finalAttrs.src.name}/ui-svelte";

  meta = (removeAttrs llama-swap.meta [ "mainProgram" ]) // {
    description = "${llama-swap.meta.description} - UI";
  };
})
