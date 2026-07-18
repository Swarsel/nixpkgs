{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docutils,
  pkg-config,
  removeReferencesTo,
  varnish,
}:
let
  common =
    {
      hash,
      version,
      extraNativeBuildInputs ? [ ],
    }:
    stdenv.mkDerivation rec {
      inherit version;
      pname = "${varnish.name}-modules";

      src = fetchFromGitHub {
        inherit hash;
        owner = "varnish";
        repo = "varnish-modules";
        tag = version;
      };

      postPatch = ''
        substituteInPlace bootstrap   --replace "''${dataroot}/aclocal"                  "${varnish.dev}/share/aclocal"
        substituteInPlace Makefile.am --replace "''${LIBVARNISHAPI_DATAROOTDIR}/aclocal" "${varnish.dev}/share/aclocal"
      '';

      nativeBuildInputs = [
        autoreconfHook
        docutils
        pkg-config
        removeReferencesTo
        varnish.python # use same python version as varnish server
      ];

      buildInputs = [ varnish ];
      postInstall = "find $out -type f -exec remove-references-to -t ${varnish.dev} '{}' +"; # varnish.dev captured only as __FILE__ in assert messages

      meta = {
        inherit (varnish.meta) license platforms;
        description = "Collection of Varnish Cache modules (vmods) by Varnish Software";
        homepage = "https://github.com/varnish/varnish-modules";
      };
    };
in
{
  modules27 = common {
    version = "0.27.0";
    hash = "sha256-1hE+AKsC6Td+Al7LFN6bgPicU8dtWd3A8PP7VKZLvYM=";
  };
}
