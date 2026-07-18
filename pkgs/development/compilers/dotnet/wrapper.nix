{
  lib,
  stdenv,
  callPackage,
  curl,
  darwin,
  expect,
  icu,
  installShellFiles,
  lndir,
  nugetPackageHook,
  pkgs,
  replaceVars,
  runCommand,
  runCommandWith,
  stdenvNoCC,
  swiftPackages,
  testers,
  writeText,
  xmlstarlet,
  zlib,
}:
type: unwrapped:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (unwrapped) version;
  pname = "${unwrapped.pname}-wrapped";
  src = unwrapped;
  outputs = [ "out" ] ++ lib.optional (unwrapped ? man) "man";
  nativeBuildInputs = [ installShellFiles ];
  propagatedBuildInputs = lib.optional (type == "sdk") nugetPackageHook;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"/bin "$out"/share
    ln -s "$src"/bin/* "$out"/bin
    ln -s "$src"/share/dotnet "$out"/share
    runHook postInstall
  '';

  postInstall = ''
    # completions snippets taken from https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
    installShellCompletion --cmd dotnet \
      --bash ${./completions/dotnet.bash} \
      --zsh ${./completions/dotnet.zsh} \
      --fish ${./completions/dotnet.fish}
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    (
      source ${./dotnet-setup-hook.sh}
      $out/bin/dotnet --info
    )
    runHook postInstallCheck
  '';

  postFixup = lib.optionalString (unwrapped ? man) ''
    ln -s ${unwrapped.man} "$man"
  '';

  dontUnpack = true;
  propagatedSandboxProfile = toString unwrapped.__propagatedSandboxProfile;

  setupHooks = [
    ./dotnet-setup-hook.sh
  ]
  ++ lib.optional (type == "sdk") (
    replaceVars ./dotnet-sdk-setup-hook.sh {
      inherit lndir xmlstarlet;
    }
  );

  passthru =
    unwrapped.passthru
    // lib.optionalAttrs (unwrapped ? artifacts) {
      inherit (unwrapped) artifacts;
    }
    // {
      inherit unwrapped;

      tests =
        let
          mkDotnetTest =
            {
              stdenv ? stdenvNoCC,
              build,
              name,
              template,
              buildInputs ? [ ],
              lang ? null,
              run ? null,
              runAllowNetworking ? false,
              runInputs ? [ ],
              runtime ? finalAttrs.finalPackage.runtime,
              usePackageSource ? false,
            }:
            let
              sdk = finalAttrs.finalPackage;
              built = stdenv.mkDerivation {
                buildInputs = [ sdk ] ++ buildInputs ++ lib.optionals usePackageSource sdk.packages;
                buildPhase = build;
                dontPatchELF = true;
                name = "${sdk.name}-test-${name}";
                # make sure ICU works in a sandbox
                propagatedSandboxProfile = toString sdk.__propagatedSandboxProfile;

                unpackPhase =
                  let
                    unpackArgs = [
                      template
                    ]
                    ++ lib.optionals (lang != null) [
                      "-lang"
                      lang
                    ];
                  in
                  ''
                    mkdir test
                    cd test
                    dotnet new ${lib.escapeShellArgs unpackArgs} -o . --no-restore
                  '';
              };
            in
            # older SDKs don't include an embedded FSharp.Core package
            if lang == "F#" && lib.versionOlder sdk.version "6.0.400" then
              null
            else if run == null then
              built
            else
              runCommand "${built.name}-run"
                (
                  {
                    src = built;
                    nativeBuildInputs = [ built ] ++ runInputs;

                    passthru = {
                      inherit built;
                    };
                  }
                  // lib.optionalAttrs (stdenv.hostPlatform.isDarwin && runAllowNetworking) {
                    __darwinAllowLocalNetworking = true;

                    sandboxProfile = ''
                      (allow network-inbound (local ip))
                      (allow mach-lookup (global-name "com.apple.FSEvents"))
                    '';
                  }
                )
                (
                  lib.optionalString (runtime != null) ''
                    export DOTNET_ROOT=${runtime}/share/dotnet
                  ''
                  + run
                );

          mkConsoleTests =
            lang: suffix: output:
            let
              # Setting LANG to something other than 'C' forces the runtime to search
              # for ICU, which will be required in most user environments.
              checkConsoleOutput = command: ''
                output="$(LANG=C.UTF-8 ${command})"
                [[ "$output" =~ ${output} ]] && touch "$out"
              '';

              mkConsoleTest =
                { name, ... }@args:
                mkDotnetTest (
                  args
                  // {
                    inherit lang;
                    name = "console-${name}-${suffix}";
                    template = "console";
                  }
                );
            in
            lib.recurseIntoAttrs {
              publish = mkConsoleTest {
                build = "dotnet publish -o $out/bin";
                name = "publish";
                run = checkConsoleOutput "$src/bin/test";
              };

              ready-to-run = mkConsoleTest {
                build = "dotnet publish --use-current-runtime -p:PublishReadyToRun=true -o $out/bin";
                name = "ready-to-run";
                run = checkConsoleOutput "$src/bin/test";
                usePackageSource = true;
              };

              run = mkConsoleTest {
                build = checkConsoleOutput "dotnet run";
                name = "run";
              };

              self-contained = mkConsoleTest {
                build = "dotnet publish --use-current-runtime --sc -o $out";
                name = "self-contained";
                run = checkConsoleOutput "$src/test";
                runtime = null;
                usePackageSource = true;
              };

              single-file = mkConsoleTest {
                build = "dotnet publish --use-current-runtime -p:PublishSingleFile=true -o $out/bin";
                name = "single-file";
                run = checkConsoleOutput "$src/bin/test";
                runtime = null;
                usePackageSource = true;
              };
            }
            // lib.optionalAttrs finalAttrs.finalPackage.hasILCompiler {
              aot = mkConsoleTest {
                buildInputs = [
                  zlib
                ]
                ++ lib.optionals stdenv.hostPlatform.isDarwin [
                  swiftPackages.swift
                  darwin.ICU
                ];

                build = ''
                  dotnet restore -p:PublishAot=true
                  dotnet publish -p:PublishAot=true -o $out/bin
                '';

                name = "aot";
                run = checkConsoleOutput "$src/bin/test";
                runtime = null;
                stdenv = if stdenv.hostPlatform.isDarwin then swiftPackages.stdenv else stdenv;
                usePackageSource = true;
              };
            };

          mkWebTest =
            lang: suffix:
            mkDotnetTest {
              inherit lang;
              build = "dotnet publish -o $out/bin";
              name = "web-${suffix}";

              run = ''
                expect <<"EOF"
                  set status 1
                  spawn $env(src)/bin/test
                  proc abort { } { exit 2 }
                  expect_before default abort
                  expect -re {Now listening on: ([^\r]+)\r} {
                    set url $expect_out(1,string)
                  }
                  expect "Application started. Press Ctrl+C to shut down."
                  set output [exec curl -sSf $url]
                  if {$output != "Hello World!"} {
                    send_error "Unexpected output: $output\n"
                    exit 1
                  }
                  send \x03
                  expect_before timeout abort
                  expect eof
                  catch wait result
                  exit [lindex $result 3]
                EOF
                touch $out
              '';

              runAllowNetworking = true;

              runInputs = [
                expect
                curl
              ];

              runtime = finalAttrs.finalPackage.aspnetcore;
              template = "web";
            };
        in
        unwrapped.passthru.tests or { }
        // {
          version = testers.testVersion {
            command = "HOME=$(mktemp -d) dotnet " + (if type == "sdk" then "--version" else "--info");
            package = finalAttrs.finalPackage;
          };
        }
        // lib.optionalAttrs (type == "sdk") {
          buildDotnetModule = lib.recurseIntoAttrs (
            (pkgs.appendOverlays [
              (self: super: {
                dotnet-runtime = finalAttrs.finalPackage.runtime;
                dotnet-sdk = finalAttrs.finalPackage;
              })
            ]).callPackage
              ../../../test/dotnet/default.nix
              { }
          );

          console = lib.recurseIntoAttrs {
            # yes, older SDKs omit the comma
            cs = mkConsoleTests "C#" "cs" "Hello,?\\ World!";
            fs = mkConsoleTests "F#" "fs" "Hello\\ from\\ F#";
            vb = mkConsoleTests "VB" "vb" "Hello,?\\ World!";
          };

          web = lib.recurseIntoAttrs {
            cs = mkWebTest "C#" "cs";
            fs = mkWebTest "F#" "fs";
          };
        };
    };

  meta = {
    inherit (unwrapped.meta)
      homepage
      license
      maintainers
      platforms
      broken
      ;

    description = "${unwrapped.meta.description or "dotnet"} (wrapper)";
    mainProgram = "dotnet";
  };
})
