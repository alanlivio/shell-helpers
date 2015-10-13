#!/bin/bash

###############################################################################
# Bash helper functions (github.com/alanlivio/bash_helper_functions)
# update by: wget raw.githubusercontent.com/alanlivio/bash_helper_functions/master/bash_helper_functions.sh
function aux_print() { echo -e "$1" | fold -w100 -s | sed '2~1s/^/  /'; }
function log_error() { aux_print "\033[00;31m---> $1 fail\033[00m"; }
function log_msg()   { aux_print "\033[00;33m---> $1\033[00m"; }
function log_done()  { aux_print "\033[00;32m---> $1 done\033[00m"; }
function log_ok()    { aux_print "\033[00;32m---> OK\033[00m"; }
function TRY()       { $*; if test $? -ne 0; then log_error "$1" && exit 1; fi;}
###############################################################################
