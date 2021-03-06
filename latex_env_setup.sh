#!/bin/bash
# This script will install texlive and all the packages required to build PDFs from the LaTeX source
# texlive files are obtained from the specified mirror. For a list of mirrors, see: http://ctan.org/mirrors/

CTAN_MIRROR_URL='http://mirror.aarnet.edu.au/pub/CTAN'

# Install texlive
wget ${CTAN_MIRROR_URL}/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xzf install-tl-unx.tar.gz && rm install-tl-unx.tar.gz
sudo ./install-tl-*/install-tl -repository ${CTAN_MIRROR_URL}/systems/texlive/tlnet -no-gui -profile texlive.profile

# Install basic texlive scheme as we're gonna install the required packages below
sudo /usr/local/texlive/2013/bin/x86_64-linux/tlmgr -repository ${CTAN_MIRROR_URL}/systems/texlive/tlnet install mdframed preprint enumitem etoolbox titlesec xmpincl comment latexmk lm memoir listings xcolor url l3packages l3kernel placeins microtype float latex-bin fancyhdr graphics psnfss pdftex-def oberdiek colortbl hyperref

