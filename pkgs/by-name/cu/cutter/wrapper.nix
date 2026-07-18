{
  lib,
  cutter,
  makeWrapper,
  plugins,
  rizin,
  symlinkJoin,
  isCutter ? false,
}:

let
  unwrapped = if isCutter then cutter else rizin;
in
symlinkJoin {
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm $out/bin/*
    wrapperArgs=(--set NIX_RZ_PREFIX $out${lib.optionalString isCutter " --prefix XDG_DATA_DIRS : $out/share"})
    for binary in $(ls ${unwrapped}/bin); do
      makeWrapper ${unwrapped}/bin/$binary $out/bin/$binary "''${wrapperArgs[@]}"
    done
  '';

  name = "${unwrapped.pname}-with-plugins-${unwrapped.version}";
  # NIX_RZ_PREFIX only changes where *Rizin* locates files (plugins,
  # themes, etc). But we must change it even for wrapping Cutter, because
  # Cutter plugins often have associated Rizin plugins. This means that
  # $out (which NIX_RZ_PREFIX will be set to) must always contain Rizin
  # files, even if we only wrap Cutter - so for Cutter, include Rizin to
  # symlinkJoin paths.
  paths = [ unwrapped ] ++ lib.optional isCutter rizin ++ plugins;

  passthru = {
    inherit unwrapped;
  };

  meta = unwrapped.meta // {
    # prefer wrapped over unwrapped
    priority = (unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
  };
}
