{
  version = "4.5.1-stable";

  default = {
    exportTemplatesHash = "sha256-GZivN/E4doTiwhHNtIPa9JL8ZNxrEglr3c3KJbaRDIY=";
  };

  hash = "sha256-8iMhn40y7aVL6Xjvo34ZtfygJYWwDmCnTxUJcV3AQCI=";

  mono = {
    exportTemplatesHash = "sha256-xCVjMGG7SfQ5C9zs4rnOaLOwvjxxCVtAZE2PbxexFG4=";
    nugetDeps = ./deps.json;
  };
}
