{
  lib,
  dotslash,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dotslash";
  version = "0.5.7";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-VFesGum2xjknUuCwIojntdst5dmhvZb78ejJ2OG1FVI=";
  };

  cargoHash = "sha256-+FWDeR4AcFSFz0gGQ8VMvX68/F0yEm25cNfHeedqsWE=";
  doCheck = false; # http tests

  passthru = {
    tests = testers.testVersion {
      package = dotslash;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simplified multi-platform executable deployment";

    longDescription = ''
      DotSlash is a command-line tool that is designed to facilitate fetching an
      executable, verifying it, and then running it. It maintains a local cache
      of fetched executables so that subsequent invocations are fast.

      DotSlash helps keeps heavyweight binaries out of your repo while ensuring
      your developers seamlessly get the tools they need, ensuring consistent
      builds across platforms.
    '';

    homepage = "https://dotslash-cli.com";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ thoughtpolice ];
    mainProgram = "dotslash";
  };
})
