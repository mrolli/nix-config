# Install and configure mpv
# https://nix-community.github.io/home-manager/options/home-manager/programs/mpv.html
# https://mpv.io/manual/
{ ... }:
{
  den.aspects.mpv.homeManager = {
    programs.mpv = {
      enable = true;

      config = {
        autofit-larger = "100%x100%";
        autofit-smaller = "1000x1000";
        #ytdl-raw-options="cookies-from-browser=Safari";
        hwdec = true;
      };

      profiles = {
        no-video = {
          no-video = true;
        };
        # secondary-screen = {
        #   screen = 1;
        # };
      };

      bindings = {
        "Alt+3" = "set window-scale 3.0";
        "Alt+4" = "set window-scale 4.0";
        "Alt+5" = "set window-scale 5.0";
      };
    };
  };
}
