{
  lib,
  stdenv,
  rtpPath,
  toVimPlugin,
}:

{
  addRtp = drv: lib.warn "`addRtp` is deprecated, does nothing." drv;

  buildVimPlugin =
    {
      src,
      addonInfo ? null,
      buildPhase ? ":",
      configurePhase ? ":",
      meta ? { },
      name ? "${attrs.pname}-${attrs.version}",
      path ? ".",
      postInstall ? "",
      preInstall ? "",
      unpackPhase ? "",
      ...
    }@attrs:
    let
      drv = stdenv.mkDerivation (
        attrs
        // {
          inherit
            unpackPhase
            configurePhase
            buildPhase
            addonInfo
            preInstall
            postInstall
            ;

          installPhase = ''
            runHook preInstall

            target=$out/${rtpPath}/${path}
            mkdir -p $out/${rtpPath}
            cp -r . $target

            runHook postInstall
          '';

          __structuredAttrs = true;
          name = lib.warnIf (attrs ? vimprefix) "The 'vimprefix' is now hardcoded in toVimPlugin" name;

          meta = {
            platforms = lib.platforms.all;
          }
          // meta;
        }
      );
    in
    toVimPlugin drv;

}
