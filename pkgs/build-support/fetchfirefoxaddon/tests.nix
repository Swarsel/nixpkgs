{
  fetchurl,
  fetchFirefoxAddon,
  testers,
  ...
}:

{
  overridden-source =
    let
      image-search-options = fetchurl {
        sha256 = "sha256-H73YWX/DKxvhEwKpWOo7orAQ7c/rQywpljeyxYxv0Gg=";
        url = "https://addons.mozilla.org/firefox/downloads/file/3059971/image_search_options-3.0.12-fx.xpi";
      };
    in
    testers.invalidateFetcherByDrvHash fetchFirefoxAddon {
      src = image-search-options;
      name = "image-search-options";
    };

  simple = testers.invalidateFetcherByDrvHash fetchFirefoxAddon {
    name = "image-search-options";
    sha256 = "sha256-H73YWX/DKxvhEwKpWOo7orAQ7c/rQywpljeyxYxv0Gg=";
    # Chosen because its only 147KB
    url = "https://addons.mozilla.org/firefox/downloads/file/3059971/image_search_options-3.0.12-fx.xpi";
  };
}
