{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "result";
  version = "1.5";

  src = fetchurl {
    url = "https://github.com/janestreet/result/releases/download/${finalAttrs.version}/result-${finalAttrs.version}.tbz";
    sha256 = "0cpfp35fdwnv3p30a06wd0py3805qxmq3jmcynjc3x2qhlimwfkw";
  };

  meta = {
    description = "Compatibility Result module";

    longDescription = ''
      Projects that want to use the new result type defined in OCaml >= 4.03
      while staying compatible with older version of OCaml should use the
      Result module defined in this library.
    '';

    homepage = "https://github.com/janestreet/result";
    license = lib.licenses.bsd3;
  };
})
