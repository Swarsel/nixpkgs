{
  lib,
  derivationWithMeta,
  kaem,
  kaem-unwrapped,
  mescc-tools,
  mescc-tools-extra,
  platforms,
  version,
  writeText,
}:

# Once mescc-tools-extra is available we can install kaem at /bin/kaem
# to make it findable in environments
derivationWithMeta {
  inherit version kaem-unwrapped;
  pname = "kaem";
  PATH = lib.makeBinPath [ mescc-tools-extra ];

  args = [
    "--verbose"
    "--strict"
    "--file"
    (builtins.toFile "kaem-wrapper.kaem" ''
      mkdir -p ''${out}/bin
      cp ''${kaem-unwrapped} ''${out}/bin/kaem
      chmod 555 ''${out}/bin/kaem
    '')
  ];

  builder = kaem-unwrapped;

  passthru.runCommand =
    name: env: buildCommand:
    derivationWithMeta (
      {
        inherit name;

        PATH = lib.makeBinPath (
          (env.nativeBuildInputs or [ ])
          ++ [
            kaem
            mescc-tools
            mescc-tools-extra
          ]
        );

        args = [
          "--verbose"
          "--strict"
          "--file"
          (writeText "${name}-builder" buildCommand)
        ];

        builder = "${kaem}/bin/kaem";
      }
      // (removeAttrs env [ "nativeBuildInputs" ])
    );

  meta = {
    inherit platforms;
    description = "Minimal build tool for running scripts on systems that lack any shell";
    homepage = "https://github.com/oriansj/mescc-tools";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
