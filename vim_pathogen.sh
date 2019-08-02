#!/bin/bash
# vim pathogen scala go hightlight (updated)
mkdir -p ~/.vim/bundle ~/.vim/autoload
cd ~/.vim/bundle; git clone https://github.com/derekwyatt/vim-scala.git; git clone https://github.com/fatih/vim-go.git; git clone https://github.com/ekalinin/Dockerfile.vim.git
cd ~/.vim/autoload; wget -v https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cd ~/.vim/; git clone https://github.com/zxqfl/tabnine-vim
echo "execute pathogen#infect()" >> ~/.vimrc
echo "set rtp+=~/.vim/tabnine-vim" >> ~/.vimrc
echo "set encoding=utf-8" >> ~/.vimrc
echo "done, check vim plugin with any code to confirm ML assisted code autocompletion"
