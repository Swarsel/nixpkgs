{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  jq,
  runCommand,
}:

let
  version = "1.1.411";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "pyright";
    tag = version;
    hash = "sha256-MamU2Mx7BSH+NVXHnKEzCbXHmWmo7V8c7BPjz6+0pAY=";
  };

  patchedPackageJSON =
    runCommand "package.json"
      {
        nativeBuildInputs = [ jq ];
      }
      ''
        jq '
          .devDependencies |= with_entries(select(.key == "glob" or .key == "jsonc-parser"))
          | .scripts =  {  }
          ' ${src}/package.json > $out
      '';

  pyright-root = buildNpmPackage {
    inherit version src;
    pname = "pyright-root";

    postPatch = ''
      cp ${patchedPackageJSON} ./package.json
      cp ${./package-lock.json} ./package-lock.json
    '';

    npmDepsHash = "sha256-EQlF3zBNnEvVGLC6btSkXGRPJHoR+Jz23ay2X9nYZSg=";

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}"; # required for update.sh script
  };

  pyright-internal = buildNpmPackage {
    inherit version src;
    pname = "pyright-internal";
    npmDepsHash = "sha256-h0ZPqVpMMnhfqP+471xzKVhWTgyuyMcfIAcrnBJZsr4=";

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}/packages/pyright-internal";
  };
in
buildNpmPackage rec {
  inherit version src;
  pname = "pyright";

  postPatch = ''
    chmod +w ../../
    ln -s ${pyright-root}/node_modules ../../node_modules
    chmod +w ../pyright-internal
    ln -s ${pyright-internal}/node_modules ../pyright-internal/node_modules
  '';

  npmDepsHash = "sha256-mVcK3FzHccBnWzUgrczhwTPhVxyR56E5i8l2GJGYlLo=";
  dontNpmBuild = true;
  sourceRoot = "${src.name}/packages/pyright";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Type checker for the Python language";
    homepage = "https://github.com/Microsoft/pyright";
    changelog = "https://github.com/Microsoft/pyright/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kalekseev ];
    mainProgram = "pyright";
  };
}
