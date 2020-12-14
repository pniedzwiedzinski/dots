pkgs:
  pkgs.writeScriptBin "todos" ''
    #!${pkgs.stdenv.shell}
    case $BLOCK_BUTTON in
      1) notify-send "Tasks" "\n$(todoist l | cut -d\  -f5- | sed 's/^/* /')" ;;
	    6) "$TERMINAL" -e "$EDITOR" "$0" ;;
    esac

    echo "✅$(todoist list | wc -l)"
  ''
