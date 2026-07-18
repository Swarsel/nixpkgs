{
  lib,
  callPackage,
  llvmPackages,
  stdenvNoCC,
  testers,
  xwin,
}:
let
  version = (builtins.fromJSON (builtins.readFile ./manifest.json)).info.buildVersion;

  hashes = (builtins.fromJSON (builtins.readFile ./hashes.json));

  fetchWinSdk = callPackage ./fetchWinSdk.nix { };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "win-sdk";

  src = fetchWinSdk {
    hash = hashes.${finalAttrs.src.arch};
    manifest = ./manifest.json;
  };

  strictDeps = true;

  nativeBuildInputs = [
    xwin
  ];

  installPhase = ''
    runHook preInstall

    xwin "''${xwinArgs[@]}"

    mkdir -p "$out"
    cp -r splat/* "$out"

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontFixup = true;

  xwinArgs = [
    "--accept-license"
    "--cache-dir=."
    "--manifest=${./manifest.json}"
    "--arch=${finalAttrs.src.arch}"
    "splat"
    "--preserve-ms-arch-notation"
  ];

  passthru = {
    tests = {
      hello-world = testers.runCommand {
        nativeBuildInputs = [
          llvmPackages.clang-unwrapped
          llvmPackages.bintools-unwrapped
        ];

        name = "hello-msvc";

        script = ''
          set -euo pipefail

          cat > hello.c <<- EOF
          #include <stdio.h>

          int main(int argc, char* argv[]) {
              printf("Hello world!\n");
              return 0;
          }
          EOF

          clang-cl --target=x86_64-pc-windows-msvc -fuse-ld=lld \
              /vctoolsdir ${finalAttrs.finalPackage}/crt \
              /winsdkdir ${finalAttrs.finalPackage}/sdk \
              ./hello.c -v

          if test ! -f hello.exe; then
            echo "hello.exe not found!"
            exit 1
          else
            touch $out
          fi
        '';
      };
    };

    updateScript = ./update.nu;
  };

  meta = {
    description = "MSVC SDK and Windows CRT for cross compiling";
    homepage = "https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/";

    license = {
      deprecated = false;
      free = false;
      fullName = "Microsoft Software License Terms";
      shortName = "msvc";
      spdxId = "unknown";
      url = "https://www.visualstudio.com/license-terms/mt644918/";
    };

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.RossSmyth ];
    platforms = lib.platforms.all;
    # The arm32 manifest is missing critical pieces.
    broken = stdenvNoCC.hostPlatform.isAarch32;
    teams = [ lib.teams.windows ];
  };
})
