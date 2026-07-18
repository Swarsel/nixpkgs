{
  lib,
  fetchFromGitHub,
  buildNimPackage,
}:
buildNimPackage (
  final: prev: rec {
    pname = "nimlangserver";
    version = "1.14.0";

    src = fetchFromGitHub {
      owner = "nim-lang";
      repo = "langserver";
      rev = "v${version}";
      hash = "sha256-IJbuM/AhPgyfe/1ONY8Nb46+gqjduVQOvkgGafgkhY4=";
    };

    doCheck = false;
    # nix build ".#nimlangserver.src"
    # nix run "github:daylinmorgan/nnl" -- result/nimble.lock -o:pkgs/by-name/ni/nimlangserver/lock.json --git,=,bearssl,zlib
    lockFile = ./lock.json;

    meta = final.src.meta // {
      description = "Nim language server implementation (based on nimsuggest)";
      homepage = "https://github.com/nim-lang/langserver";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ daylinmorgan ];
      mainProgram = "nimlangserver";
    };
  }
)
