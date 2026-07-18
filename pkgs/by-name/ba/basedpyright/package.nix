{
  lib,
  stdenv,
  fetchFromGitHub,
  basedpyright,
  buildNpmPackage,
  clang_20,
  docify,
  jq,
  libsecret,
  nix-update-script,
  pkg-config,
  runCommand,
  testers,
  versionCheckHook,
  writeText,
}:

buildNpmPackage rec {
  pname = "basedpyright";
  version = "1.39.8";

  src = fetchFromGitHub {
    owner = "detachhead";
    repo = "basedpyright";
    tag = "v${version}";
    hash = "sha256-8S83CTd/td7USKxfCI0cXd2gPBMivi4QMRQwVgxhs6w=";
  };

  nativeBuildInputs = [
    docify
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin clang_20; # clang_21 breaks keytar

  buildInputs = [ libsecret ];
  npmDepsHash = "sha256-humpJB+fv3+PITcPCz3uY2jNANb3P7sXy0lFP8Eg58I=";

  preBuild = ''
    # Build the docstubs
    cp -r packages/pyright-internal/typeshed-fallback docstubs
    docify docstubs/stdlib --builtins-only --in-place
  '';

  postInstall = ''
    mv "$out/bin/pyright" "$out/bin/basedpyright"
    mv "$out/bin/pyright-langserver" "$out/bin/basedpyright-langserver"
    # Remove dangling symlinks created during installation (remove -delete to just see the files, or -print '%l\n' to see the target
    find -L $out -type l -print -delete
    # Remove native module build artifacts that reference nodejs source
    rm -rf "$out/lib/node_modules/pyright-root/node_modules/keytar/build"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  npmWorkspace = "packages/pyright";

  passthru = {
    tests = {
      # We are expecting 4 errors. Any other amount would indicate not working
      # stub files, for instance.
      simple = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [
                jq
                basedpyright
              ];

              base = writeText "test.py" ''
                import sys
                from time import tzset

                def print_string(a_string: str):
                    a_string += 42
                    print(a_string)

                if sys.platform == "win32":
                    print_string(69)
                    this_function_does_not_exist("nice!")
                else:
                    result_of_tzset_is_None: str = tzset()
              '';

              configFile = writeText "pyproject.toml" ''
                [tool.pyright]
                typeCheckingMode = "strict"
              '';
            }
            ''
              (basedpyright --outputjson $base || true) | jq -r .summary.errorCount > $out
            '';

        assertion = "simple type checking";

        expected = writeText "expected" ''
          4
        '';
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Type checker for the Python language";
    homepage = "https://github.com/detachhead/basedpyright";
    changelog = "https://github.com/detachhead/basedpyright/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kiike
      misilelab
    ];

    mainProgram = "basedpyright";
  };
}
