{
  programs.starship = {
    enable = true;
    # enableFishIntegration = true; I'd set it to true, but instead I'm doing it manually, since enable_transience is being broken
    settings = {
      format = ''
        ([\[](fg:8)$package$rust$username$hostname$cmd_duration$jobs[\]](fg:8))
        $directory([\[](fg:8)$git_branch$git_state$git_status$git_metrics[\]](fg:8))$fill$status$time
        $character
      '';
      scan_timeout = 10;
      add_newline = true;
      username = {
        show_always = false;
        format = "[$user@](fg:8)";
      };
      hostname = {
        ssh_only = true;
        format = "[$hostname](fg:8) ";
      };
      directory = {
        style = "bold blue";
        read_only = " ";
        truncate_to_repo = false;
        format = "[ $path]($style)[$read_only]($read_only_style) ";
        fish_style_pwd_dir_length = 1;
        truncation_length = 1;
        home_symbol = "~";
      };
      git_branch = {
        format = " [$symbol$branch]($style) ";
        symbol = "";
      };
      git_status = {
        format = "([$conflicted$deleted$renamed$modified$staged$untracked$ahead_behind]($style))";
        style = "bold cyan";
        up_to_date = "";
        conflicted = "=$count ";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕$count ";
        untracked = "?$count ";
        stashed = "$$count ";
        modified = "!$count ";
        staged = "+$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
      };
      git_metrics = {
        disabled = false;
        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
      };
      jobs = {
        disabled = false;
        format = " bg jobs: [$symbol$number]($style) ";
        number_threshold = 1;
        symbol = "";
      };
      package = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
      };
      cmd_duration = {
        min_time = 2000;
      };
      status = {
        disabled = false;
        format = "[(✖ $status $common_meaning )](bold red)";
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      fill = {
        symbol = " ";
      };
      time = {
        disabled = false;
      };
    };
  };
}
