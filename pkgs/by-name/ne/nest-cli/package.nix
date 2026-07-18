{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  clang_20,
  python3,
}:

buildNpmPackage (finalAttrs: {
  pname = "nest-cli";
  version = "11.0.18";

  src = fetchFromGitHub {
    owner = "nestjs";
    repo = "nest-cli";
    tag = finalAttrs.version;
    hash = "sha256-fqVsvox7c50bZ5jqGrpu3QiQG+ghY3eh8SETrdKnRCY=";
  };

  nativeBuildInputs = [
    python3
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [ clang_20 ]; # clang_21 breaks gyp builds

  npmDepsHash = "sha256-1M53H0tLD3+9To4kxt136P7kOvzo3gfWEFkFlcUSy6g=";

  env = {
    npm_config_build_from_source = true;
  };

  npmFlags = [ "--legacy-peer-deps" ];

  meta = {
    description = "CLI tool for Nest applications";
    homepage = "https://nestjs.com";
    changelog = "https://github.com/nestjs/nest-cli/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ehllie
      phanirithvij
    ];

    mainProgram = "nest";
    downloadPage = "https://github.com/nestjs/nest-cli";
  };
})
