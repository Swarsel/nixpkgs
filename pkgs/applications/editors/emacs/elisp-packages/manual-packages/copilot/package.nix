{
  lib,
  fetchFromGitHub,
  copilot-language-server,
  dash,
  editorconfig,
  f,
  jsonrpc,
  melpaBuild,
  nodejs,
  s,
}:
melpaBuild (finalAttrs: {
  pname = "copilot";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "copilot-emacs";
    repo = "copilot.el";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-x2Lzhz8Yi3/EsahkJZ/pJoaJuVb1xIHgNt50qi0ndeo=";
  };

  postPatch = ''
    substituteInPlace copilot.el \
      --replace-fail "defcustom copilot-server-executable \"copilot-language-server\"" \
                     "defcustom copilot-server-executable \"${lib.getExe copilot-language-server}\""
  '';

  files = ''(:defaults "dist")'';

  packageRequires = [
    dash
    editorconfig
    f
    jsonrpc
    s
  ];

  propagatedUserEnvPkgs = [ nodejs ];

  meta = {
    description = "Unofficial copilot plugin for Emacs";
    homepage = "https://github.com/copilot-emacs/copilot.el";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bbigras ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
      "x86_64-windows"
    ];
  };
})
