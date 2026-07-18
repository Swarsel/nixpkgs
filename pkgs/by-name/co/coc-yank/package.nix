{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  esbuild,
  nix-update-script,
  nodejs_22,
}:
let
  esbuild' =
    let
      version = "0.25.0";
    in
    esbuild.override {
      buildGoModule =
        args:
        buildGoModule (
          args
          // {
            inherit version;

            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-L9jm94Epb22hYsU3hoq1lZXb5aFVD4FC4x2qNt0DljA=";
            };

            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          }
        );
    };
in

buildNpmPackage (finalAttrs: {
  pname = "coc-yank";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-yank";
    tag = finalAttrs.version;
    hash = "sha256-AREGlb8YDRwma9QtLeoted5S0ordS8Hcd2umYQfKq9g=";
  };

  nativeBuildInputs = [ esbuild' ];
  npmDepsHash = "sha256-ISHILT/FBy2Y0UWaQkjMm5ZsYacNt3M54IJ8ckYjq3A=";
  env.ESBUILD_BINARY_PATH = lib.getExe esbuild';
  # https://github.com/NixOS/nixpkgs/issues/474535
  nodejs = nodejs_22;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Yank highlight and persist yank history support for vim";
    homepage = "https://github.com/neoclide/coc-yank";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
