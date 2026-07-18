{ lib, fetchurl, ... }:
fetchurl (finalAttrs: {
  pname = "prototype";
  version = "1.7.3.0";
  name = "${finalAttrs.pname}-${finalAttrs.version}.js";
  sha256 = "0q43vvrsb22h4jvavs1gk3v4ps61yx9k85b5n6q9mxivhmxprg26";
  url = "https://ajax.googleapis.com/ajax/libs/prototype/${finalAttrs.version}/prototype.js";

  meta = {
    description = "Foundation for ambitious web user interfaces";

    longDescription = ''
      Prototype takes the complexity out of client-side web
      programming. Built to solve real-world problems, it adds
      useful extensions to the browser scripting environment
      and provides elegant APIs around the clumsy interfaces
      of Ajax and the Document Object Model.
    '';

    homepage = "http://prototypejs.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ das_j ];
    downloadPage = "http://prototypejs.org/download/";
  };
})
