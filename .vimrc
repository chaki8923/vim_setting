set path+=**

" Leaderキー(デフォルトの \) をスペースキーに変更する
let mapleader = "\<Space>"

"========================================
" プラグインのインストール設定 (vim-plug)
"========================================
call plug#begin('~/.vim/plugged')

" 2. ファイラー (今回は動作が軽い fern.vim を有効化)
Plug 'lambdalisue/fern.vim'
" ※NERDTreeを使いたい場合は上の行を消し、下の行の「"」を外してください
" Plug 'preservim/nerdtree'

" 3. ファジーファインダー (fzf.vim)
" ※fzf本体とVim用プラグインの両方をインストールします
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 4. ステータスライン (シンプルで綺麗な lightline.vim を有効化)
Plug 'itchyny/lightline.vim'
" ※vim-airlineを使いたい場合は上の行を消し、下の行の「"」を外してください
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" 5. 自動補完・LSP (coc.nvim) 
" ※動作にはOSに Node.js がインストールされている必要があります
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

" [fzf.vim] 検索のショートカットキー
nnoremap <C-p> :Files<CR>  " Ctrl+p でファイル検索
nnoremap <C-g> :GFiles<CR> " Ctrl+g でGit管理ファイルのみ検索

" Ctrl+c でファイル全文をMacのクリップボードにコピー
nnoremap <C-c> :%w !pbcopy<CR><CR>

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
  " 1. ファイルの「絶対パス」を確実に取得（Vimの起動場所に左右されない）
  let l:filepath = expand('%:p')
  
  " 2. パスから 'api' や 'batch' を抽出
  let l:app_name = matchstr(l:filepath, '/apps/\zs[^/]\+')
  if l:app_name ==# ''
    let l:app_name = 'api'
  endif

  " 3. アプリのルート以降のパス (例: spec/lib/...) を正確に抽出
  let l:test_target = matchstr(l:filepath, '/apps/' . l:app_name . '/\zs.*')
  
  " 4. vim-test が渡してくる cmd から、行番号指定(例: :42)があれば抽出
  let l:line_num = matchstr(a:cmd, ':\d\+$')

  " 5. 完璧なDockerコマンドを組み立て
  return 'docker exec -t ibjs_api /bin/bash -c "cd ' . l:app_name . ' && RAILS_ENV=test bundle exec rspec ' . l:test_target . l:line_num . '"'
endfunction

" 上記の関数をDocker環境用のルールとして登録
let g:test#custom_transformations = {'docker_api': function('DockerTransform')}
let g:test#transformation = 'docker_api'

" ショートカットキーの設定 (バックスラッシュキー + t など)
" カーソルがある行のテストだけを実行 (単一example)
nnoremap <silent> <Leader>t :TestNearest<CR>
" 今開いているファイル全体のテストを実行
nnoremap <silent> <Leader>T :TestFile<CR>

" モーダル（ターミナル）を開いている時に Esc を押したら一発で閉じる
tnoremap <silent> <Esc> <C-\><C-n>:FloatermKill<CR>
" モーダルがノーマルモード（結果表示中）になった時も Esc で閉じる
autocmd FileType floaterm nnoremap <buffer> <silent> <Esc> :FloatermKill<CR>
