colorscheme monokai
set nocompatible
set number relativenumber
set number ruler laststatus=2 title hlsearch wildmenu
"set term=tmux-256color
set term=screen-256color
set cursorline
hi CursorLine term=bold cterm=bold

" Powerline Theme for Vim
"python3 from powerline.vim import setup as powerline_setup
"python3 powerline_setup()
"python3 del powerline_setup
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode    " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256

" Detect if vim Plug needs to be installed
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'edkolev/tmuxline.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
" avoid conflict with vimtex
let g:polyglot_disabled = ['latex']

Plug 'christoomey/vim-tmux-navigator'
Plug 'crusoexia/vim-monokai'
Plug 'valloric/youcompleteme'

Plug 'vimwiki/vimwiki'
"
" Ensure files are read as what I want:
let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}

" Vimtex
Plug 'lervag/vimtex'
let g:vimtex_fold_enabled = 1
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
"set conceallevel=1
"let g:tex_conceal='abdmg'

" Improved Conceal
Plug 'pietropate/vim-tex-conceal'
set conceallevel=2
let g:tex_conceal="abdgms"

" Snippets
Plug 'SirVer/ultisnips'
" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "my_snippets"]
"Plug 'vim-latex/vim-latex'
"Plug 'nathanaelkane/vim-indent-guides'
call plug#end()

" Proper indentation of new lines
filetype indent plugin on
syntax on                           " Syntax highlighting

" Show white spaces everywhere
"set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
"set list

" Format text
set textwidth=80
set wrapmargin=2

set expandtab
set tabstop=4
set shiftwidth=4
set smartindent

set hidden " allow me to have buffers with unsaved changes.
set autoread " when a file has changed on disk, just load it. Don't ask.

" Make search more sane
set ignorecase " case insensitive search
set smartcase " If there are uppercase letters, become case-sensitive.
set incsearch " live incremental searching
set showmatch " live match highlighting
set hlsearch " highlight matches
set gdefault " use the `g` flag by default.
set spell spelllang=en_gb " spell check
"
" allow the cursor to go anywhere in visual block mode.
set virtualedit+=block

" leader is a key that allows you to have your own "namespace" of keybindings.
let mapleader = ","

" We don't have to press shift when we want to get into command mode.
nnoremap ; :
vnoremap ; :

" create new vsplit, and switch to it.
noremap <leader>v <C-w>v

" Use sane regex's when searching
nnoremap / /\v
vnoremap / /\v

nnoremap <leader>l :set cursorcolumn!<CR>

" Clear match highlighting
noremap <leader><space> :noh<cr>:call clearmatches()<cr>

" Latex key bindings
autocmd FileType tex nmap <buffer> <C-M> :!latexmk -pdf %<CR>

" Quick buffer switching - like cmd-tab'ing
nnoremap <leader><leader> <c-^>
" Improve multiple buffers navigation
let g:airline#extensions#tabline#enabled = 1

nnoremap <buffer> <F5> :!python3.7 %<cr>   " Run python script
"
" Quickly open projects note file
"nmap <script>n<CR> <SID>:tabe tmp/notes.md<CR>
nmap <script>n<CR> <SID>:tab drop tmp/notes.md<CR>


" If you wrap lines, vim by default won't let you move down one line to the
" wrapped portion. This fixes that.
noremap j gj
noremap k gk

" Text-editing mode (wrapping lines correctly, etc)
let s:wrapenabled = 0
function! ToggleWrap()
  set wrap nolist
  if s:wrapenabled
    set nolinebreak
    unmap j
    unmap k
    unmap 0
    unmap ^
    unmap $
    let s:wrapenabled = 0
  else
    set linebreak
    nnoremap j gj
    nnoremap k gk
    nnoremap 0 g0
    nnoremap ^ g^
    nnoremap $ g$
    vnoremap j gj
    vnoremap k gk
    vnoremap 0 g0
    vnoremap ^ g^
    vnoremap $ g$
    let s:wrapenabled = 1
  endif
endfunction
map <leader>w :call ToggleWrap()<CR> " use: , w
