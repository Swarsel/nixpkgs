{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  hicolor-icon-theme,
  pkg-config,
  wrapGAppsHook3,
  xfce,
  xfce4-dev-tools,
}:

{
  category,
  pname,
  sha256,
  version,
  attrPath ? "xfce.${pname}",
  meta ? { },
  odd-unstable ? true,
  passthru ? { },
  patchlevel-unstable ? true,
  rev ? "${rev-prefix}${version}",
  rev-prefix ? "${pname}-",
  ...
}@args:

let
  inherit (builtins)
    filter
    getAttr
    head
    isList
    ;
  inherit (lib)
    attrNames
    concatLists
    recursiveUpdate
    zipAttrsWithNames
    ;

  filterAttrNames = f: attrs: filter (n: f (getAttr n attrs)) (attrNames attrs);

  concatAttrLists =
    attrsets: zipAttrsWithNames (filterAttrNames isList (head attrsets)) (_: concatLists) attrsets;

  template = {
    src = fetchFromGitLab {
      inherit rev sha256;
      owner = category;
      repo = pname;
      domain = "gitlab.xfce.org";
    };

    outputs = [
      "out"
      "dev"
    ];

    nativeBuildInputs = [
      pkg-config
      xfce4-dev-tools
      wrapGAppsHook3
    ];

    buildInputs = [ hicolor-icon-theme ];
    configureFlags = [ "--enable-maintainer-mode" ];
    enableParallelBuilding = true;
    pos = builtins.unsafeGetAttrPos "pname" args;

    passthru = {
      updateScript = gitUpdater {
        inherit rev-prefix odd-unstable patchlevel-unstable;
      };
    }
    // passthru;

    meta =

      {
        homepage = "https://gitlab.xfce.org/${category}/${pname}";
        license = lib.licenses.gpl2Plus; # some libraries are under LGPLv2+
        platforms = lib.platforms.linux;
      }
      // meta;
  };

  publicArgs = removeAttrs args [
    "category"
    "sha256"
  ];
in

stdenv.mkDerivation (
  publicArgs
  // template
  // concatAttrLists [
    template
    args
  ]
)
