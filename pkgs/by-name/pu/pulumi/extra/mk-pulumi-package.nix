{
  lib,
  fetchFromGitHub,
  buildGoModule,
  python3Packages,
}:
let
  mkBasePackage =
    {
      cmd,
      env,
      extraLdflags,
      pname,
      src,
      vendorHash,
      version,
      ...
    }@args:
    buildGoModule (
      {
        doCheck = false;

        ldflags = [
          "-s"
          "-w"
        ]
        ++ extraLdflags;

        sourceRoot = "${src.name}/provider";
        subPackages = [ "cmd/${cmd}" ];
      }
      // args
    );

  mkPythonPackage =
    {
      meta,
      pname,
      src,
      version,
      ...
    }@args:
    python3Packages.callPackage (
      {
        buildPythonPackage,
        parver,
        pip,
        pulumi,
        semver,
        setuptools,
      }:
      buildPythonPackage (
        {
          inherit
            pname
            meta
            src
            version
            ;

          postPatch = ''
            if [[ -e "pyproject.toml" ]]; then
              sed -i \
                -e 's/^  version = .*/  version = "${version}"/g' \
                pyproject.toml
            else
              sed -i \
                 -e 's/^VERSION = .*/VERSION = "${version}"/g' \
                 -e 's/^PLUGIN_VERSION = .*/PLUGIN_VERSION = "${version}"/g' \
                 setup.py
            fi
          '';

          propagatedBuildInputs = [
            parver
            pulumi
            semver
            setuptools
          ];

          # Auto-generated; upstream does not have any tests.
          # Verify that the version substitution works
          checkPhase = ''
            runHook preCheck

            ${pip}/bin/pip show "${pname}" | grep "Version: ${version}" > /dev/null \
              || (echo "ERROR: Version substitution seems to be broken"; exit 1)

            runHook postCheck
          '';

          pyproject = true;

          pythonImportsCheck = [
            (builtins.replaceStrings [ "-" ] [ "_" ] pname)
          ];

          sourceRoot = "${src.name}/sdk/python";
        }
        // args
      )
    ) { };
in
{
  cmdGen,
  cmdRes,
  extraLdflags,
  hash,
  meta,
  owner,
  repo,
  rev,
  vendorHash,
  version,
  env ? { },
  fetchSubmodules ? false,
  pythonArgs ? { },
  ...
}@args:
let
  src = fetchFromGitHub {
    inherit
      owner
      repo
      rev
      hash
      fetchSubmodules
      ;

    name = "source-${repo}-${rev}";
  };

  pulumi-gen = mkBasePackage {
    inherit
      src
      version
      vendorHash
      extraLdflags
      env
      ;

    pname = cmdGen;
    cmd = cmdGen;
  };
in
mkBasePackage (
  {
    inherit env src;
    pname = repo;

    nativeBuildInputs = [
      pulumi-gen
    ];

    postConfigure = ''
      pushd ..

      chmod +w sdk/
      ${cmdGen} schema

      popd

      VERSION=v${version} go generate cmd/${cmdRes}/main.go
    '';

    cmd = cmdRes;

    passthru.sdks.python = mkPythonPackage (
      {
        inherit meta src version;
        pname = repo;
      }
      // pythonArgs
    );
  }
  // (lib.removeAttrs args [ "pythonArgs" ])
)
