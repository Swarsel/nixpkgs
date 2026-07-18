{
  buildNpmPackage,
  fetchNpmDeps,
  meta,
  src,
  version,
}:
buildNpmPackage (finalAttrs: {
  inherit src version;
  pname = "lasuite-meet-mail";

  postPatch = ''
    substituteInPlace bin/html-to-plain-text bin/mjml-to-html \
      --replace-fail \
        '../backend/core/templates/mail' \
        '${placeholder "out"}'
  '';

  dontInstall = true;
  npmBuildScript = "build";

  npmDeps = fetchNpmDeps {
    inherit version src;
    inherit (finalAttrs) sourceRoot;
    pname = "${finalAttrs.pname}-npm-deps";
    hash = "sha256-EPVkSzhecDZpvz+uOW0GZnmWl9KfE3UpkTCnhVnJ7dg=";
  };

  sourceRoot = "${finalAttrs.src.name}/src/mail";

  meta = meta // {
    description = "HTML mail templates for LaSuite Meet";
  };
})
