"========================================
" 基本設定
"========================================
" :find でサブディレクトリのファイルも検索できるようにする
set path+=**

" コマンドラインのTab補完をVSCodeのサジェストのように一覧表示する
set wildmenu

" Leaderキー(デフォルトの \) をスペースキーに変更する
let mapleader = "\<Space>"

" 裏側でバッファ(ファイル)を開きっぱなしにする（タブ管理に必須）
set hidden

"========================================
" プラグインのインストール設定 (vim-plug)
"========================================
call plug#begin('~/.vim/plugged')

" 2. ファイラー (fern.vim)
Plug 'lambdalisue/fern.vim'

" 3. ファジーファインダー (fzf.vim)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 4. ステータスライン＆タブバー (vim-airline)
" ※lightline と buftabline を削除し、こちらに統合しました
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 5. 自動補完・LSP (coc.nvim) 
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 6. Git連携 (vim-fugitive)
Plug 'tpope/vim-fugitive'

" 7. 括弧やクォーテーション操作 (vim-surround)
Plug 'tpope/vim-surround'

Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'mhinz/vim-startify'

" テスト実行とモーダル表示用プラグイン
Plug 'janko/vim-test'
Plug 'voldikss/vim-floaterm'

call plug#end()


"========================================
" プラグインを便利に使うためのキー設定
"========================================
" [fern.vim] Ctrl+n で左側にツリー画面を開閉する
nnoremap <C-n> :Fern . -drawer -toggle<CR>
" ツリー(Fern)で隠しファイルをデフォルトで表示する
let g:fern#default_hidden = 1

" [fzf.vim] プロジェクト全体を絶対に検索するための設定
function! s:find_git_root()
  let l:root = systemlist('git rev-parse --show-toplevel')[0]
  return v:shell_error ? '.' : l:root
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()

" Ctrl+p で必ずプロジェクト全体検索を開く
nnoremap <silent> <C-p> :ProjectFiles<CR>

" Ctrl+c でファイル全文をMacのクリップボードにコピー
nnoremap <C-c> :%w !pbcopy<CR><CR>


" ========================================
" Airline (ステータスバー＆タブバー) の設定
" ========================================
" 上部にバッファ（ファイル）をタブとして一覧表示する
let g:airline#extensions#tabline#enabled = 1
" タブにファイル名だけをスッキリ表示する
let g:airline#extensions#tabline#fnamemod = ':t'

" Tabキーで次のタブ(バッファ)へ、Shift + Tabで前のタブへ移動
nnoremap <silent> <Tab> :bnext<CR>
nnoremap <silent> <S-Tab> :bprev<CR>

" Ctrl + w で現在のタブ（ファイル）を閉じる
nnoremap <silent> <C-w> :bdelete<CR>


" ========================================
" テスト実行 (vim-test + floaterm) の設定
" ========================================
" モーダル(フローティングウィンドウ)で結果を表示する
let test#strategy = "floaterm"
" モーダルのサイズ調整 (画面の80%の大きさ)
let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
let g:floaterm_title = ' RSpec '

function! DockerTransform(cmd) abort
  let l:filepath = expand('%:p')
  let l:app_name = matchstr(l:filepath, '/apps/\zs[^/]\+')
  if l:app_name ==# ''
    let l:app_name = 'api'
  endif
  let l:test_target = matchstr(l:filepath, '/apps/' . l:app_name . '/\zs.*')
  let l:line_num = matchstr(a:cmd, ':\d\+$')
  return 'docker exec -t ibjs_api /bin/bash -c "cd ' . l:app_name . ' && RAILS_ENV=test bundle exec rspec ' . l:test_target . l:line_num . '"'
endfunction

let g:test#custom_transformations = {'docker_api': function('DockerTransform')}
let g:test#transformation = 'docker_api'

" カーソルがある行のテストだけを実行 (単一example)
nnoremap <silent> <Leader>t :TestNearest<CR>
" 今開いているファイル全体のテストを実行
nnoremap <silent> <Leader>T :TestFile<CR>

" モーダル（ターミナル）を開いている時に Esc を押したら一発で閉じる (Floaterm限定)
autocmd FileType floaterm tnoremap <buffer> <silent> <Esc> <C-\><C-n>:FloatermKill<CR>
" モーダルがノーマルモード（結果表示中）になった時も Esc で閉じる
autocmd FileType floaterm nnoremap <buffer> <silent> <Esc> :FloatermKill<CR>
