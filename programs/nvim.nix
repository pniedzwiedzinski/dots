## Usage


{ pkgs, ... }: 
pkgs.neovim.override {
  configure = {
    customRC = ''
      let mapleader =","

      if ! filereadable(system('echo -n "$HOME/.config/nvim/autoload/plug.vim"'))
        echo "Downloading junegunn/vim-plug to manage plugins..."
        silent !mkdir -p $HOME/.config/nvim/autoload/
        silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > $HOME/.config/nvim/autoload/plug.vim
        autocmd VimEnter * PlugInstall
      endif

      set bg=light
      set go=a
      set mouse=a
      set nohlsearch
      set clipboard+=unnamedplus

      " Some basics:
        nnoremap c "_c
        set nocompatible
        filetype plugin on
        syntax on
        set encoding=utf-8
        set number relativenumber
      " Enable autocompletion:
        set wildmode=longest,list,full
      " Disables automatic commenting on newline:
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

      " Goyo plugin makes text more readable when writing prose:
        map <leader>f :Goyo \| set bg=light \| set linebreak<CR>

      " Spell-check set to <leader>o, 'o' for 'orthography':
        map <leader>o :setlocal spell! spelllang=en_us<CR>

      " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
        set splitbelow splitright

      " Nerd tree
        map <leader>n :NERDTreeToggle<CR>
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
          if has('nvim')
              let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
          else
              let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
          endif

      " vimling:
        nm <leader>d :call ToggleDeadKeys()<CR>
        imap <leader>d <esc>:call ToggleDeadKeys()<CR>a
        nm <leader>i :call ToggleIPA()<CR>
        imap <leader>i <esc>:call ToggleIPA()<CR>a
        nm <leader>q :call ToggleProse()<CR>

      " Shortcutting split navigation, saving a keypress:
        map <C-h> <C-w>h
        map <C-j> <C-w>j
        map <C-k> <C-w>k
        map <C-l> <C-w>l

      " Replace ex mode with gq
        map Q gq

      " Check file in shellcheck:
        map <leader>s :!clear && shellcheck %<CR>

      " Open my bibliography file in split
        map <leader>b :vsp<space>$BIB<CR>
        map <leader>r :vsp<space>$REFER<CR>

      " Replace all is aliased to S.
        nnoremap S :%s//g<Left><Left>

      " Compile document, be it groff/LaTeX/markdown/etc.
        map <leader>c :w! \| !compiler <c-r>%<CR>

      " Open corresponding .pdf/.html or preview
        map <leader>p :!opout <c-r>%<CR><CR>

      " Runs a script that cleans out tex build files whenever I close out of a .tex file.
        autocmd VimLeave *.tex !texclear %

      " Ensure files are read as what I want:
        let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
        map <leader>v :VimwikiIndex
        let g:vimwiki_list = [{'path': '~/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
        autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
        autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
        autocmd BufRead,BufNewFile *.tex set filetype=tex

      " Save file as sudo on files that require root permission
        cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

      " Enable Goyo by default for mutt writing
        autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
        autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=light
        autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
        autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>

      " Automatically deletes all trailing whitespace and newlines at end of file on save.
        autocmd BufWritePre * %s/\s\+$//e
        autocmd BufWritepre * %s/\n\+\%$//e

      " When shortcut files are updated, renew bash and ranger configs with new material:
        autocmd BufWritePost bm-files,bm-dirs !shortcuts
      " Run xrdb whenever Xdefaults or Xresources are updated.
        autocmd BufWritePost *Xresources,*Xdefaults,*xresources,*xdefaults !xrdb %

      " Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
      if &diff
          highlight! link DiffText MatchParen
      endif

      set tabstop=2
      set shiftwidth=2
      set expandtab
      set linebreak
      set colorcolumn=80
      highlight ColorColumn ctermbg=8


      let g:ycm_key_list_select_completion = ['<tab>', '<Down>']
      let g:ycm_key_list_previous_completion = ['<Up>']

      let g:UltiSnipsExpandTrigger = "<S-tab>"
      let g:UltiSnipsEditSplit="vertical"
      nnoremap <silent> <C-f> :GFiles<CR>
      nnoremap <silent> <Leader>f :Rg<CR>
      map <C-n> :NERDTreeToggle<CR>

      map <F9> gg=G

      " Fuzzy finding
      set path+=**
    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        vim-surround
        vim-fugitive
        nerdtree
        goyo-vim
        # vimagit
        vimwiki
        vim-airline
        vim-commentary
        vim-css-color
        vim-nix
        UltiSnips
        vim-snippets
        YouCompleteMe
        Supertab
        fzf-vim
        pkgs.nur.repos.pn.gemini-vim-syntax

      ];
      opt = [];
    };
  };
  vimAlias = true;
  viAlias = true;
 }

