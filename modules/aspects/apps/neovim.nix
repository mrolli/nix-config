{ ... }:
{
  den.aspects.neovim.homeManager =
    {
      config,
      lib,
      ...
    }:
    let
      source = ./nvim;
      writableFiles = [
        "lazy-lock.json"
        "lazyvim.json"
        "spell/de.utf-8.add"
        "spell/en.utf-8.add"
      ];
    in
    {
      xdg.configFile."nvim" = {
        source = builtins.path {
          path = source;
          name = "neovim-config";
          filter =
            path: _:
            !(builtins.elem (lib.removePrefix "${toString source}/" (toString path)) writableFiles);
        };
        recursive = true;
      };

      home.activation.seedNeovimState = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        nvimConfig=${lib.escapeShellArg "${config.xdg.configHome}/nvim"}
        run mkdir -p "$nvimConfig/spell"
        for file in ${lib.concatMapStringsSep " " lib.escapeShellArg writableFiles}; do
          if [ ! -e "$nvimConfig/$file" ] && [ ! -L "$nvimConfig/$file" ]; then
            run install -m 0644 "${source}/$file" "$nvimConfig/$file"
          fi
        done
      '';
    };
}
