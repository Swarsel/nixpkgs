{
  lib,
  buildNpmPackage,
  src,
  version,
}:

buildNpmPackage {
  inherit src version;
  pname = "photoprism-frontend";

  postPatch = ''
    cd frontend
  '';

  npmDepsHash = "sha256-RjPTtIm1BhyeQLUN9mWI+sXakNju4up0FbrdwZzkTS0=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ../assets $out/

    runHook postInstall
  '';

  # Some dependencies are fetched from git repositories
  forceGitDeps = true;
  makeCacheWritable = true;

  meta = {
    description = "Photoprism's frontend";
    homepage = "https://photoprism.app";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ benesim ];
  };
}
