{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "ghw";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "jaypipes";
    repo = "ghw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-olMKS+Bb+YK43I23zvxCp9XFkknwvqXorrYVlVomL+o=";
  };

  vendorHash = "sha256-REgtByhTlYQ3XyYleWAcrCymIWtWmltjx21tr2mtF7k=";
  doCheck = false; # wants to read from /sys and other places not allowed
  subPackages = [ "cmd/..." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go HardWare discovery/inspection library";
    homepage = "https://github.com/jaypipes/ghw";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mmlb ];
    mainProgram = "ghwc";
  };
})
