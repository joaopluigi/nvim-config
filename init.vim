syntax on
syntax enable
filetype plugin on

call plug#begin('~/.local/share/nvim/plugged')

" themes
Plug 'joshdick/onedark.vim'

" fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" statusline/tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" text manipulation: surround parentheses, brackets, quotes, etc
Plug 'guns/vim-sexp'
Plug 'tpope/vim-surround'

" use . to repeat plugin mappings 
Plug 'tpope/vim-repeat'

" better mappings for text manipulation
Plug 'tpope/vim-sexp-mappings-for-regular-people'

" file system explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" git diff in the sign column.
Plug 'airblade/vim-gitgutter'

" git diff visualization in a split view
Plug 'tpope/vim-fugitive'

" rainbow parentheses
Plug 'luochen1990/rainbow'

" comment out stuff
Plug 'tpope/vim-commentary'

" multi-line edit
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" multi Language parser
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

" Dispatch
Plug 'tpope/vim-dispatch'
Plug 'clojure-vim/vim-jack-in'
Plug 'radenling/vim-dispatch-neovim'

" lsp client: coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-highlight', { 'do': 'yarn install --frozen-lockfile && yarn build' }
Plug 'iamcco/coc-vimlsp', { 'do': 'yarn install --frozen-lockfile && yarn build' }

" Clojure REPL
Plug 'Olical/conjure', {'tag': 'v4.17.0'}

" devicons
Plug 'ryanoasis/vim-devicons'

" Display text with ANSI escape sequences (8 or 16 colors)
Plug 'm00qek/baleia.nvim'

" tab management
Plug 'm00qek/nvim-contabs'

call plug#end()

"""
" visual settings
"""

set clipboard=unnamed " make operations such as yy, D, and P work with the clipboard 
set encoding=UTF-8 " file encoding
colorscheme onedark " theme
set number " display line numbers
set mouse=a " enable mouse
set tabstop=2 " tab width
set shiftwidth=2 " shift width
set expandtab " space instead of tab
" set nohlsearch " turnoff search highlight
set completeopt=menuone,noinsert,noselect " set completeopt to have a better completion experience
set nowrap " does not allow line wrap


"""
" rainbow parentheses
"""

let g:rainbow_active = 1

"""
" airline
"""

let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
let g:airline#extensions#coc#enabled = 1
let airline#extensions#coc#error_symbol = ' '
let airline#extensions#coc#warning_symbol = ' '

""" 
" nerdtree
"""

let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeIgnore = []
let NERDTreeStatusline = ''
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" nerdtree-git-plugin
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

" contabs
" " configure where to look for projects
" " - folders in $NU_HOME that are git repos
" " - Neovim config folder
let g:contabs#project#locations = [
\ { 'path': '$NU_HOME',
\   'depth': 1,
\   'git_only': v:true,
\   'entrypoint': ['src/*/service.clj', 'project.clj'] },
\ { 'path': '~/.config/nvim',
\   'entrypoint': [ 'init.vim' ],
\   'formatter': { _ -> 'Neovim (~/.config/nvim)' } }
\]

" " configure native tabline
let g:contabs#integrations#tabline#theme = 'project/pathshorten'
set tabline=%!contabs#integrations#tabline#create()

" " command to open a project in current tab
command! -nargs=1 -complete=dir EP call contabs#project#edit(<q-args>)

" " command to open a project in a new tab
command! -nargs=1 -complete=dir TP call contabs#project#tabedit(<q-args>)

" conjure
let g:conjure#client#clojure#nrepl#test#current_form_names = ['deftest', 'defflow']

" baleia
" " tell Conjure to not strip ANSI sequences
let g:conjure#log#strip_ansi_escape_sequences_line_limit = 0
let s:highlighter = luaeval("require('baleia').setup(require('baleia.options').conjure())")

function! s:remove_ansi(tid)
  let l:save = winsaveview()
  try | %s/\%x1b[[:;0-9]*m//g | catch 'E486' | endtry
  call winrestview(l:save)
endfunction

function! s:enable_colors() 
  "immediately hide all escape sequences
  syntax match BaleiaAnsiEscapeCodes /\%x1b\[[:;0-9]*m/ conceal
  setlocal conceallevel=2
  setlocal concealcursor=nvic

  " remove them after some time
  call timer_start(300, funcref('s:remove_ansi'))

  if exists('b:baleia') && b:baleia == v:true 
    return
  endif
  let b:baleia = v:true

  call s:highlighter.automatically(bufnr('%'))
endfunction

autocmd BufEnter conjure-log-* call s:enable_colors()

"""
" treesitter 
"""

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "clojure", "go", "javascript", "json", "python", "regex", "typescript" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
  },
}
EOF

"""
" coc.nvim config
"""

let g:coc_global_extensions = ['coc-conjure', 'coc-tsserver', 'coc-json', 'coc-prettier', 'coc-styled-components', 'coc-eslint', 'coc-react-refactor' , 'coc-html', 'coc-jest', 'coc-highlight', 'coc-css']

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.0 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"""""" clojure-lsp refactoring
function! Expand(exp) abort
    let l:result = expand(a:exp)
    return l:result ==# '' ? '' : "file://" . l:result
endfunction

nnoremap <silent> crcc :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'cycle-coll', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crth :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'thread-first', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crtt :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'thread-last', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crtf :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'thread-first-all', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crtl :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'thread-last-all', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> cruw :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'unwind-thread', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crua :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'unwind-all', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crml :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'move-to-let', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1, input('Binding name: ')]})<CR>
nnoremap <silent> cril :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'introduce-let', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1, input('Binding name: ')]})<CR>
nnoremap <silent> crel :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'expand-let', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> cram :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'add-missing-libspec', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crcn :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'clean-ns', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> crcp :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'cycle-privacy', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> cris :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'inline-symbol', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1]})<CR>
nnoremap <silent> cref :call CocRequest('clojure-lsp', 'workspace/executeCommand', {'command': 'extract-function', 'arguments': [Expand('%:p'), line('.') - 1, col('.') - 1, input('Function name: ')]})<CR>

""""" commands
command! -nargs=0 Prettier :CocCommand prettier.formatFile

"""
" Custom functions
"""

set splitright
set splitbelow

tnoremap <Esc> <C-\><C-j>

function! ConfigCredentials()
  Dispatch nu aws credentials refresh 
endfunction

function! ConfigNvim()
  tabnew ~/.config/nvim/init.vim
endfunction

function! LintClojure()
  Dispatch lein lint
endfunction

function! REPLClojure()
  Lein! with-profiles +repl repl :headless
endfunction

function! TestClojure()
  ConjureCljRunCurrentNsTests
endfunction

function! TestNpm()
  vsplit +term\ npm\ run-script\ test 
	vertical resize 45
endfunction

"""
" Custom mapping
"""

let mapleader='\'
let maplocalleader=','

" Set config.json.base files JSOn syntax
autocmd BufNewFile,BufRead *.json.base set syntax=json

" map fzf GFiles on normal mode to ;
nmap ; :GFiles<CR>

" map fzf GFiles? on normal mode to "
nmap <LocalLeader>; :GFiles?<CR>

" fuzzy search for projects
" - <CR>  open selected project in current tab
" - <C-T> open selected project in a new tab
nnoremap <silent> <LocalLeader>p :call contabs#project#select()<CR>

" fuzzy search for open buffers
nnoremap <silent> <LocalLeader>b :call contabs#buffer#select()<CR>

" map NERDTreeToggle on normal mode to CTRL+M
nmap <C-m> :NERDTreeToggle<CR>

" map CTRL+c on command line to run lint
cmap <C-c> call Config

" map CTRL+l on command line to run lint
cmap <C-l> call Lint

" map CTRL+r on command line to run REPL 
cmap <C-r> call REPL

" map CTRL+t on command line to run tests
cmap <C-t> call Test

" move between tabs with CTRL+-> and CTRL+<-
map <C-Left>  gT
map <C-Right> gt
