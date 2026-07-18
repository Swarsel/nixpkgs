{ melpaBuild, ott }:

melpaBuild {
  inherit (ott) src version;
  pname = "ott-mode";

  postPatch = ''
    pushd emacs
    echo ";;; ott-mode.el ---" > tmp.el
    cat ott-mode.el >> tmp.el
    mv tmp.el ott-mode.el
    popd
  '';

  files = ''("emacs/*.el")'';

  meta = {
    inherit (ott.meta) homepage license;
    description = "Emacs ott mode (from ott sources)";
  };
}
