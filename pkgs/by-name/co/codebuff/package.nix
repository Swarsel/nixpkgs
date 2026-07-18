{
  lib,
  buildNpmPackage,
  fetchzip,
}:

buildNpmPackage (finalAttrs: {
  pname = "codebuff";
  version = "1.0.681";

  src = fetchzip {
    url = "https://registry.npmjs.org/codebuff/-/codebuff-${finalAttrs.version}.tgz";
    hash = "sha256-tkQ8MOkQk4vaS9PFqlFBV6unEgysXcwHrKGgxfe60fM=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  strictDeps = true;
  npmDepsHash = "sha256-KB0QCfpGP32O5dU+/2dOEmX87iclJrZudIkTNp9ZxSw=";
  dontNpmBuild = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Use natural language to edit your codebase and run commands from your terminal faster";
    homepage = "https://www.codebuff.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.malo ];
    mainProgram = "codebuff";
    downloadPage = "https://www.npmjs.com/package/codebuff";
  };
})
