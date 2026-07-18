{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  nix-update-script,
  php,
  re2c,
}:

{
  pname,
  version,
  buildInputs ? [ ],
  internalDeps ? [ ],
  makeFlags ? [ ],
  nativeBuildInputs ? [ ],
  passthru ? { },
  peclDeps ? [ ],
  postPhpize ? "",
  src ? fetchurl (
    {
      url = "https://pecl.php.net/get/${pname}-${version}.tgz";
    }
    // lib.filterAttrs (
      attrName: _:
      lib.elem attrName [
        "sha256"
        "hash"
      ]
    ) args
  ),
  ...
}@args:

stdenv.mkDerivation (
  args
  // {
    inherit src;
    strictDeps = true;

    nativeBuildInputs = [
      php
      autoreconfHook
      re2c
    ]
    ++ nativeBuildInputs;

    buildInputs = [ php ] ++ peclDeps ++ buildInputs;
    makeFlags = [ "EXTENSION_DIR=$(out)/lib/php/extensions" ] ++ makeFlags;
    checkPhase = "NO_INTERACTON=yes make test";

    autoreconfPhase = ''
      phpize
      ${postPhpize}
      ${lib.concatMapStringsSep "\n" (
        dep: "mkdir -p ext; ln -s ${dep.dev}/include ext/${dep.extensionName}"
      ) internalDeps}
    '';

    extensionName = pname;
    name = "php-${pname}-${version}";

    passthru = passthru // {
      # Thes flags were introduced for `nix-update` so that it can update
      # PHP extensions correctly.
      # See the corresponding PR: https://github.com/Mic92/nix-update/pull/123
      isPhpExtension = true;
      updateScript = passthru.updateScript or (nix-update-script { });
    };
  }
)
