"plugins
"
call plug#begin('~/.vim/plugged') "where to store plugin

Plug 'fatih/vim-go' "vim-go for debugging, testing, build ...
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
Plug 'preservim/nerdtree'



call plug#end()

" settings
"
filetype on "detect files type based on type
filetype indent on "maintain indentation
set nu "enable line numbers

" coc settings
"
" keymap
nmap<silent> gd <Plug>(coc-definition)
nmap<silent> gy <Plug>(coc-type-definition)
nmap<silent> gi <Plug>(coc-implementation)
nmap<silent> gr <Plug>(coc-references)


" renmap
vmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
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
inoremap <silent><expr> <c-space> coc#refresh()

" NERDTree settings
let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="-"

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-t> :NERDTreeToggle<CR>


