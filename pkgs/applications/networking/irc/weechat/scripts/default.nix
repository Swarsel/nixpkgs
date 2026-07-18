{
  callPackage,
  luaPackages,
  perlPackages,
  python3Packages,
}:

{
  autosort = callPackage ./autosort { };
  buffer_autoset = callPackage ./buffer_autoset { };
  colorize_nicks = callPackage ./colorize_nicks { };
  edit = callPackage ./edit { };
  highmon = callPackage ./highmon { };

  multiline = callPackage ./multiline {
    inherit (perlPackages) PodParser;
  };

  url_hint = callPackage ./url_hint { };
  wee-slack = callPackage ./wee-slack { };
  weechat-autosort = callPackage ./weechat-autosort { };
  weechat-go = callPackage ./weechat-go { };
  weechat-grep = callPackage ./weechat-grep { };
  weechat-matrix = python3Packages.callPackage ./weechat-matrix { };

  weechat-matrix-bridge = callPackage ./weechat-matrix-bridge {
    inherit (luaPackages) cjson luaffi;
  };

  weechat-notify-send = python3Packages.callPackage ./weechat-notify-send { };
  weechat-otr = callPackage ./weechat-otr { };
  zncplayback = callPackage ./zncplayback { };
}
