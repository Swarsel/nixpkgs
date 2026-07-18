{
  mkTmuxPlugin,
  replaceVars,
  thumbs,
}:

mkTmuxPlugin {

  inherit (thumbs) version src meta;

  patches = [
    (replaceVars ./fix.patch {
      tmuxThumbsDir = "${thumbs}/bin";
    })
  ];

  pluginName = thumbs.src.repo;
  rtpFilePath = "tmux-thumbs.tmux";

}
