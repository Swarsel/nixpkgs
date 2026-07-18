{
  lib,
  callPackage,
  fetchPypi,
  fetchpatch,
  python,
  runCommand,
  encryptionSupport ? true,
  sqliteSupport ? true,
}:

let
  maubot = python.pkgs.buildPythonPackage (finalAttrs: {
    pname = "maubot";
    version = "0.6.0";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-ZXwyctTjKg1ssYE6Ehc1s1DPhWyc08dIQ4MQz6EQXGg=";
    };

    patches = [
      # add entry point - https://github.com/maubot/maubot/pull/146
      (fetchpatch {
        hash = "sha256-d5fu47F93aXZmk6MiSsxTE8pHjMKNL0FUdU+ynUqY2o=";
        url = "https://github.com/maubot/maubot/commit/ef6e23eccb530187dd3447b6aac2047d4a32fb83.patch";
      })
    ];

    postInstall = ''
      rm $out/example-config.yaml
    '';

    build-system = with python.pkgs; [
      setuptools
    ];

    dependencies =
      with python.pkgs;
      [
        # requirements.txt
        (mautrix.override { withOlm = encryptionSupport; })
        aiohttp
        yarl
        asyncpg
        aiosqlite
        commonmark
        ruamel-yaml
        attrs
        bcrypt
        packaging
        click
        colorama
        questionary
        jinja2
      ]
      # optional-requirements.txt
      ++ lib.optionals encryptionSupport [
        python-olm
        pycryptodome
        unpaddedbase64
      ]
      ++ lib.optionals sqliteSupport [
        sqlalchemy_1_3
      ];

    # used for plugin tests
    propagatedNativeBuildInputs = with python.pkgs; [
      pytest
      pytest-asyncio
    ];

    pyproject = true;

    pythonImportsCheck = [
      "maubot"
    ];

    pythonRelaxDeps = [
      "bcrypt"
      "ruamel.yaml"
    ];

    passthru =
      let
        wrapper = callPackage ./wrapper.nix {
          python3 = python;
          unwrapped = maubot;
        };
      in
      {
        inherit python;

        plugins = callPackage ./plugins {
          maubot = maubot;
          python3 = python;
        };

        tests = {
          simple = runCommand "${finalAttrs.pname}-tests" { } ''
            ${maubot}/bin/mbc --help > $out
          '';
        };

        # This changes example-config.yaml in module directory
        withBaseConfig = baseConfig: wrapper { inherit baseConfig; };
        # This adds the plugins to lib/maubot-plugins
        withPlugins = plugins: wrapper { inherit plugins; };
        withPythonPackages = pythonPackages: wrapper { inherit pythonPackages; };
      };

    meta = {
      description = "Plugin-based Matrix bot system written in Python";
      homepage = "https://maubot.xyz/";
      changelog = "https://github.com/maubot/maubot/blob/v${finalAttrs.version}/CHANGELOG.md";
      license = lib.licenses.agpl3Plus;
      maintainers = with lib.maintainers; [ chayleaf ];
      # Presumably, people running "nix run nixpkgs#maubot" will want to run the tool
      # for interacting with Maubot rather than Maubot itself, which should be used as
      # a NixOS module.
      mainProgram = "mbc";
    };
  });

in
maubot
